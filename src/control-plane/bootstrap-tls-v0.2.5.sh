#!/usr/bin/bash
# INPSan S4 evaluation TLS bootstrap
# Generates an ephemeral loopback-only self-signed certificate for validation.
set -u

OUT="${1:-/var/tmp/inpsan-s4-tls-bootstrap}"
OPENSSL=/usr/bin/openssl

[ -x "$OPENSSL" ] || { echo "openssl_missing=FAIL"; exit 2; }

rm -rf "$OUT"
mkdir -p "$OUT"
chmod 700 "$OUT"

KEY="$OUT/inpsan-eval.key.pem"
CERT="$OUT/inpsan-eval.cert.pem"
CONF="$OUT/openssl.cnf"

cat >"$CONF" <<'EOF'
[ req ]
default_bits = 3072
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[ dn ]
C = XX
O = INPSan Evaluation
OU = Security Validation
CN = localhost

[ v3_req ]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF

"$OPENSSL" req   -x509   -newkey rsa:3072   -sha256   -nodes   -days 60   -keyout "$KEY"   -out "$CERT"   -config "$CONF" >/dev/null 2>&1 || exit 1

chmod 600 "$KEY"
chmod 644 "$CERT"
chmod 600 "$CONF"

"$OPENSSL" x509 -in "$CERT" -noout -subject -issuer -serial -enddate -fingerprint -sha256

MODE=$(/usr/bin/perl -e '@s=stat($ARGV[0]); printf "%04o", $s[2]&07777' "$KEY")
echo "key_mode=$MODE"
[ "$MODE" = "0600" ] || exit 1

echo "tls_bootstrap=PASS"
echo "tls_cert=$CERT"
echo "tls_key=$KEY"
