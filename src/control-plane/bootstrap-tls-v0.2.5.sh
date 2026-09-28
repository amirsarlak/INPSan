#!/usr/bin/bash
# INPSan S4 evaluation TLS bootstrap
# Creates a local evaluation CA and loopback server certificate.
set -u

OUT="${1:-/var/tmp/inpsan-s4-tls-bootstrap}"
OPENSSL=/usr/bin/openssl

[ -x "$OPENSSL" ] || { echo "openssl_missing=FAIL"; exit 2; }

rm -rf "$OUT"
mkdir -p "$OUT"
chmod 700 "$OUT"

CA_KEY="$OUT/inpsan-eval-ca.key.pem"
CA_CERT="$OUT/inpsan-eval-ca.cert.pem"
KEY="$OUT/inpsan-eval-server.key.pem"
CSR="$OUT/inpsan-eval-server.csr.pem"
CERT="$OUT/inpsan-eval-server.cert.pem"
CA_CONF="$OUT/ca.cnf"
SERVER_CONF="$OUT/server.cnf"
EXT_CONF="$OUT/server-ext.cnf"

cat >"$CA_CONF" <<'EOF'
[ req ]
default_bits = 3072
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_ca

[ dn ]
C = XX
O = INPSan Evaluation
OU = Security Validation CA
CN = INPSan Evaluation Root CA

[ v3_ca ]
basicConstraints = critical,CA:TRUE
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
EOF

cat >"$SERVER_CONF" <<'EOF'
[ req ]
default_bits = 3072
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
C = XX
O = INPSan Evaluation
OU = Security Validation
CN = localhost
EOF

cat >"$EXT_CONF" <<'EOF'
[ v3_server ]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

[ alt_names ]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF

"$OPENSSL" req -x509 -newkey rsa:3072 -sha256 -nodes -days 60   -keyout "$CA_KEY" -out "$CA_CERT" -config "$CA_CONF" >/dev/null 2>&1 || exit 1

"$OPENSSL" req -new -newkey rsa:3072 -sha256 -nodes   -keyout "$KEY" -out "$CSR" -config "$SERVER_CONF" >/dev/null 2>&1 || exit 1

"$OPENSSL" x509 -req -in "$CSR"   -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial   -days 60 -sha256   -extfile "$EXT_CONF" -extensions v3_server   -out "$CERT" >/dev/null 2>&1 || exit 1

chmod 600 "$CA_KEY" "$KEY" "$CA_CONF" "$SERVER_CONF" "$EXT_CONF"
chmod 644 "$CA_CERT" "$CERT"
rm -f "$CSR" "$OUT/inpsan-eval-ca.cert.srl"

"$OPENSSL" verify -CAfile "$CA_CERT" "$CERT" || exit 1
"$OPENSSL" x509 -in "$CERT" -noout -subject -issuer -serial -enddate -fingerprint -sha256

MODE=$(/usr/bin/perl -e '@s=stat($ARGV[0]); printf "%04o", $s[2]&07777' "$KEY")
echo "key_mode=$MODE"
[ "$MODE" = "0600" ] || exit 1

echo "tls_bootstrap=PASS"
echo "tls_ca=$CA_CERT"
echo "tls_cert=$CERT"
echo "tls_key=$KEY"
