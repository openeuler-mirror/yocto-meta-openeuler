#!/usr/bin/env bash
# patch-audit.sh — audit the multi-source patches of an openEuler Embedded recipe.
#
# Modes:
#   dead   <recipe-dir>   list *.patch files under <recipe-dir> that no
#                         .bb/.bbappend/.inc in that dir references (dead patches)
#   fuzz   <do_patch-log> report fuzz / offset / failed / rejected hunks
#   order  <do_patch-log> list applied patch order with the resolved source path
#   spec   <spec-file>    list Patch* declarations grouped by number range and
#                         the arch-conditional reverts (%ifnarch / %patchNNNN -R)
#   xcheck <spec-file> <recipe-dir-or-bbappend>
#                         cross-check spec-declared patches vs SRC_URI-referenced
#                         ones: MISSING (lou-da) / EXTRA / explicitly REMOVED
#   stale  <bbappend-or-dir> <base-recipe-or-dir>
#                         flag SRC_URI:remove entries absent from the base recipe
#                         (stale no-op removes left over after a version bump)
#
# Exit codes: 0 = clean, 1 = findings (dead / fuzz / missing / stale), 2 = usage.
set -uo pipefail

usage() { sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; }
die()   { echo "ERROR: $*" >&2; exit 2; }

mode="${1:-}"
[ -n "$mode" ] || { usage; exit 2; }
shift || true

case "$mode" in
  dead)
    dir="${1:-}"; [ -d "$dir" ] || die "dead: need an existing recipe dir"
    refs="$(mktemp)"
    # basenames referenced from any SRC_URI-style file:// entry in recipe metadata
    grep -rhoE 'file://[^ ;"\\]+' "$dir" \
         --include='*.bb' --include='*.bbappend' --include='*.inc' 2>/dev/null \
      | sed -E 's#^file://##; s#[;?].*##; s#.*/##' | sort -u > "$refs"
    found=0
    while IFS= read -r f; do
      b="$(basename "$f")"
      if ! grep -qxF -- "$b" "$refs"; then
        echo "DEAD (unreferenced): $f"
        found=1
      fi
    done < <(find "$dir" -name '*.patch' -type f | sort)
    rm -f "$refs"
    [ "$found" -eq 0 ] && echo "OK: no dead patches under $dir"
    exit "$found"
    ;;

  fuzz)
    log="${1:-}"; [ -f "$log" ] || die "fuzz: need an existing do_patch log"
    if grep -nEi 'with fuzz|Hunk #[0-9]+ FAILED|offset [0-9]+ lines|does not apply|malformed patch|rejected' "$log"; then
      echo "--- fuzz/offset/failed findings above (exit 1) ---"
      exit 1
    fi
    echo "OK: no fuzz/offset/failed hunks in $log"
    exit 0
    ;;

  order)
    log="${1:-}"; [ -f "$log" ] || die "order: need an existing do_patch log"
    grep -nE "Applying patch" "$log" \
      | sed -E "s/^[0-9]+:NOTE: Applying patch '([^']+)' \(([^)]*)\).*/\1\t<- \2/" \
      | nl
    exit 0
    ;;

  spec)
    spec="${1:-}"; [ -f "$spec" ] || die "spec: need an existing .spec file"
    echo "=== other Patch* (build/path adaptation, e.g. Patch1 / Patch251) ==="
    grep -nE '^Patch[0-9]+:' "$spec" | grep -vE '^[0-9]+:Patch[69][0-9]{3}:' || echo "(none)"
    echo "=== backport range (Patch6xxx) ==="
    grep -nE '^Patch6[0-9]{3}:' "$spec" || echo "(none)"
    echo "=== openEuler custom range (Patch9xxx) ==="
    grep -nE '^Patch9[0-9]{3}:' "$spec" || echo "(none)"
    echo "=== arch-conditional apply/revert in %prep ==="
    grep -nE '%ifnarch|%ifarch|%patch[0-9]+ +-R' "$spec" || echo "(none)"
    exit 0
    ;;

  xcheck)
    spec="${1:-}"; dir="${2:-}"
    [ -f "$spec" ] || die "xcheck: need an existing .spec file"
    [ -e "$dir" ] || die "xcheck: need an existing recipe dir or .bbappend file"
    sp="$(mktemp)"; ref="$(mktemp)"; rml="$(mktemp)"; ap="$(mktemp)"
    # spec-declared patch basenames (all PatchNNNN ranges)
    grep -oE '^Patch[0-9]+:[[:space:]]+[^[:space:]]+' "$spec" \
      | awk '{print $2}' | sed 's#.*/##' | sort -u > "$sp"
    # every file://*.patch referenced in recipe metadata (INCLUDES :remove entries)
    grep -rhoE 'file://[^ ;"\\]+\.patch' "$dir" \
         --include='*.bb' --include='*.bbappend' --include='*.inc' 2>/dev/null \
      | sed -E 's#^file://##; s#.*/##' | sort -u > "$ref"
    # patches explicitly dropped via SRC_URI:remove (handles multi-line blocks)
    find "$dir" \( -name '*.bb' -o -name '*.bbappend' -o -name '*.inc' \) -type f -print0 2>/dev/null \
      | xargs -0 awk '
          FNR==1 { inrm=0; q=0 }
          !inrm && /:remove[[:space:]]*=|_remove[[:space:]]*=/ { inrm=1; q=0 }
          inrm {
            t=$0; q+=gsub(/"/, "\"", t)
            s=$0
            while (match(s, /file:\/\/[^ ;"\\]+\.patch/)) {
              print substr(s, RSTART+7, RLENGTH-7); s=substr(s, RSTART+RLENGTH)
            }
            if (q>0 && q%2==0) inrm=0
          }' 2>/dev/null | sed 's#.*/##' | sort -u > "$rml"
    comm -23 "$ref" "$rml" > "$ap"          # applied = referenced - removed
    echo "spec=$(wc -l < "$sp")  referenced=$(wc -l < "$ref")  removed=$(wc -l < "$rml")  applied=$(wc -l < "$ap")"
    miss="$(comm -23 "$sp" "$ap")"
    extra="$(comm -13 "$sp" "$ap")"
    echo "--- MISSING (in spec, NOT applied) -> lou-da: apply it or document the skip ---"
    [ -n "$miss" ] && echo "$miss" || echo "(none)"
    echo "--- EXTRA (applied, not in spec) -> base/C-group patch, or a :remove leftover ---"
    [ -n "$extra" ] && echo "$extra" || echo "(none)"
    echo "--- REMOVED via :remove ---"
    [ -s "$rml" ] && cat "$rml" || echo "(none)"
    rm -f "$sp" "$ref" "$rml" "$ap"
    [ -n "$miss" ] && exit 1
    exit 0
    ;;

  stale)
    bb="${1:-}"; base="${2:-}"
    [ -e "$bb" ]   || die "stale: need an existing .bbappend or recipe dir"
    [ -e "$base" ] || die "stale: need the base recipe (.bb) or its dir"
    rml="$(mktemp)"; baserefs="$(mktemp)"
    # every file:// entry inside :remove blocks (patches AND .cfg fragments)
    find "$bb" \( -name '*.bb' -o -name '*.bbappend' -o -name '*.inc' \) -type f -print0 2>/dev/null \
      | xargs -0 awk '
          FNR==1 { inrm=0; q=0 }
          !inrm && /:remove[[:space:]]*=|_remove[[:space:]]*=/ { inrm=1; q=0 }
          inrm {
            t=$0; q+=gsub(/"/, "\"", t)
            s=$0
            while (match(s, /file:\/\/[^ ;"\\]+/)) {
              print substr(s, RSTART+7, RLENGTH-7); s=substr(s, RSTART+RLENGTH)
            }
            if (q>0 && q%2==0) inrm=0
          }' 2>/dev/null | sed 's#.*/##' | sort -u > "$rml"
    [ -s "$rml" ] || { echo "OK: no :remove entries under $bb"; rm -f "$rml" "$baserefs"; exit 0; }
    # basenames the base recipe actually lists in SRC_URI
    if [ -d "$base" ]; then
      grep -rhoE 'file://[^ ;"\\]+' "$base" --include='*.bb' --include='*.bbappend' --include='*.inc' 2>/dev/null
    else
      grep -hoE 'file://[^ ;"\\]+' "$base" 2>/dev/null
    fi | sed -E 's#^file://##; s#.*/##' | sort -u > "$baserefs"
    stale=0; eff=0
    while IFS= read -r f; do
      if grep -qxF -- "$f" "$baserefs"; then
        eff=$((eff+1))
      else
        echo "STALE (not in base SRC_URI -> no-op remove): $f"; stale=1
      fi
    done < "$rml"
    total="$(wc -l < "$rml")"
    echo "--- removed=$total  effective=$eff  stale_noop=$((total-eff)) ---"
    rm -f "$rml" "$baserefs"
    exit "$stale"
    ;;

  *)
    die "unknown mode '$mode' (use: dead | fuzz | order | spec | xcheck | stale)"
    ;;
esac
