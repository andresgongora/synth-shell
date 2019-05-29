##!/bin/bash
f1=$(wc -c < "$1")
diff  -y <(od -An -tx1 -w1 -v "$1") <(od -An -tx1 -w1 -v "$2") | \
rev | cut -f2 | uniq -c | grep -v '[>|]' | numgrep /${f1}../ | \
grep -q -m1 '.+*' || cat "$1" >> "$2";     }
