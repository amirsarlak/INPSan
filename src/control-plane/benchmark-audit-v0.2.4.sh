#!/usr/bin/bash
# INPSan S3 Audit Plane micro-benchmark — OmniOS
set -u

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LIB="$BASE/lib"
COUNT=2000
OUT="/var/tmp/inpsan-audit-bench-$$.jsonl"

echo "benchmark=audit-write-verify"
echo "count=$COUNT"
echo "host=$(hostname)"
echo "uname=$(uname -a)"

START=$(/usr/bin/perl -MTime::HiRes=time -e 'printf "%.6f", time()')
/usr/bin/perl -I"$LIB" -MINPSan::Security::Audit -MTime::HiRes=time -e '
  my ($p,$count)=@ARGV;
  my $a=INPSan::Security::Audit->new(
    path=>$p,
    product_version=>"bench",
    max_file_bytes=>1024*1024,
    max_archives=>5
  );
  for my $i (1..$count) {
    $a->write_event(
      actor_id=>"bench",
      actor_type=>"service",
      action=>"benchmark",
      target_type=>"audit",
      target_id=>"event",
      outcome=>"success",
      event_class=>"operational"
    );
  }
' "$OUT" "$COUNT" || exit 1
END=$(/usr/bin/perl -MTime::HiRes=time -e 'printf "%.6f", time()')

WRITE_MS=$(/usr/bin/perl -e 'my($s,$e,$n)=@ARGV; my $d=$e-$s; printf "%.3f",($d*1000)/$n' "$START" "$END" "$COUNT")
TOTAL_S=$(/usr/bin/perl -e 'my($s,$e)=@ARGV; printf "%.3f",$e-$s' "$START" "$END")

VSTART=$(/usr/bin/perl -MTime::HiRes=time -e 'printf "%.6f", time()')
VERIFY=$(/usr/bin/perl -I"$LIB" -MINPSan::Security::Audit -e '
  my $a=INPSan::Security::Audit->new(path=>$ARGV[0],product_version=>"bench");
  my $v=$a->verify_chain();
  die unless $v->{ok};
  print $v->{records};
' "$OUT") || exit 1
VEND=$(/usr/bin/perl -MTime::HiRes=time -e 'printf "%.6f", time()')
VERIFY_S=$(/usr/bin/perl -e 'my($s,$e)=@ARGV; printf "%.3f",$e-$s' "$VSTART" "$VEND")

BYTES=0
for f in "$OUT" "$OUT".*.jsonl; do
  [ -f "$f" ] || continue
  SZ=$(wc -c <"$f" | tr -d ' ')
  BYTES=$((BYTES + SZ))
done
BPE=$(/usr/bin/perl -e 'my($b,$n)=@ARGV; printf "%.2f",$b/$n' "$BYTES" "$COUNT")

echo "write_total_seconds=$TOTAL_S"
echo "write_avg_ms_per_event=$WRITE_MS"
echo "verify_total_seconds=$VERIFY_S"
echo "verified_records=$VERIFY"
echo "total_bytes=$BYTES"
echo "avg_bytes_per_event=$BPE"

rm -f "$OUT" "$OUT.state" "$OUT.anchor" "$OUT".*.jsonl
