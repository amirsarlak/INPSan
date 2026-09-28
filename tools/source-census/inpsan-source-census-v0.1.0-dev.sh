#!/usr/bin/bash
# INPSan Source/Module Census — v0.1.0-dev
# Purpose: inventory first-party source metadata without copying source content.
# Safety: read-only against product files; writes census evidence under /var/tmp.
# Related: CP-KB-001 / WP-3.3-001 / GitHub Issue #4

set -u

STAMP=$(date '+%Y%m%d-%H%M%S')
OUT=${1:-/var/tmp/inpsan-source-census-${STAMP}}
mkdir -p "$OUT" || exit 1

FILES="$OUT/files.tsv"
LANG="$OUT/language-summary.tsv"
MODULE="$OUT/module-summary.tsv"
MANIFEST="$OUT/manifest.txt"

printf 'path\tmodule\tlanguage\tbytes\tlines\tsha256\n' >"$FILES"

hash_file() {
  f=$1
  h=$(digest -a sha256 "$f" 2>/dev/null) && { printf '%s' "$h"; return; }
  h=$(sha256sum "$f" 2>/dev/null | awk '{print $1}') && { printf '%s' "$h"; return; }
  printf 'UNAVAILABLE'
}

classify() {
  f=$1
  base=$(basename "$f")
  case "$base" in
    *.pl|*.pm) echo "Perl"; return ;;
    *.js) echo "JavaScript"; return ;;
    *.css) echo "CSS"; return ;;
    *.sh) echo "Shell"; return ;;
    *.html|*.htm) echo "HTML"; return ;;
    *.xml) echo "XML"; return ;;
    *.json|*.jsonl) echo "JSON-Data"; return ;;
    *.md) echo "Markdown"; return ;;
  esac
  first=$(sed -n '1p' "$f" 2>/dev/null)
  echo "$first" | grep -qi 'perl' && { echo "Perl"; return; }
  echo "$first" | grep -Eqi '(bash|/sh)' && { echo "Shell"; return; }
  echo "Other"
}

module_of() {
  f=$1
  case "$f" in
    /opt/inpsan/*)
      rest=${f#/opt/inpsan/}
      echo "$rest" | awk -F/ '{print $1}'
      ;;
    /var/web-gui/*)
      echo "web-gui-integration"
      ;;
    *)
      echo "other"
      ;;
  esac
}

record_file() {
  f=$1
  [ -f "$f" ] || return
  lang=$(classify "$f")
  module=$(module_of "$f")
  bytes=$(wc -c <"$f" 2>/dev/null | tr -d ' ')
  lines=$(wc -l <"$f" 2>/dev/null | tr -d ' ')
  sha=$(hash_file "$f")
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$f" "$module" "$lang" "$bytes" "$lines" "$sha" >>"$FILES"
}

# First-party product tree.
if [ -d /opt/inpsan ]; then
  find /opt/inpsan -type f 2>/dev/null | sort | while IFS= read -r f; do
    record_file "$f"
  done
fi

# INPSan-specific Web-GUI assets.
for root in /var/web-gui/data/wwwroot/_my /var/web-gui/data/napp-it/_my; do
  if [ -d "$root" ]; then
    find "$root" -type f 2>/dev/null | grep -i '/inpsan' | sort | while IFS= read -r f; do
      record_file "$f"
    done
  fi
done

# Capture admin.pl only when it contains explicit INPSan integration markers.
if [ -d /var/web-gui ]; then
  find /var/web-gui -type f -path '*/cgi-bin/admin.pl' 2>/dev/null | while IFS= read -r f; do
    if grep -q 'INPSAN_' "$f" 2>/dev/null; then
      record_file "$f"
    fi
  done
fi

# De-duplicate identical paths in case roots overlap.
awk 'NR==1{print;next}!seen[$1]++' "$FILES" >"$FILES.tmp" && mv "$FILES.tmp" "$FILES"

printf 'language\tfiles\tlines\tbytes\n' >"$LANG"
awk -F '\t' 'NR>1 {f[$3]++; l[$3]+=$5; b[$3]+=$4} END {for (k in f) printf "%s\t%d\t%d\t%d\n",k,f[k],l[k],b[k]}' "$FILES" | sort >>"$LANG"

printf 'module\tfiles\tlines\tbytes\n' >"$MODULE"
awk -F '\t' 'NR>1 {f[$2]++; l[$2]+=$5; b[$2]+=$4} END {for (k in f) printf "%s\t%d\t%d\t%d\n",k,f[k],l[k],b[k]}' "$FILES" | sort >>"$MODULE"

{
  echo "census_version=0.1.0-dev"
  echo "captured_at=$(date '+%Y-%m-%dT%H:%M:%S%z')"
  echo "hostname=$(uname -n 2>/dev/null || echo unknown)"
  echo "file_count=$(awk 'END{print NR-1}' "$FILES")"
  echo "output_directory=$OUT"
  echo "contains_source_content=false"
  echo "capture_complete=true"
} >"$MANIFEST"

echo "INPSan source census written to: $OUT"
echo "Upload manifest.txt, files.tsv, language-summary.tsv and module-summary.tsv."
echo "The census contains paths, sizes, line counts and hashes — not source code contents."
