#!/usr/bin/env bash
set -euo pipefail
if [[ -n "${VM3_COPYCTX_SENTINEL:-}" ]]; then secret_present=yes; else secret_present=no; fi
echo "VM3_COPYCTX_SECRET_PRESENT=${secret_present}"
echo "VM3_COPYCTX_EVENT=${GITHUB_EVENT_NAME:-unset}"
echo "VM3_COPYCTX_HEAD=${GITHUB_HEAD_REF:-unset}"
echo "VM3_COPYCTX_BASE=${GITHUB_BASE_REF:-unset}"
echo "VM3_COPYCTX_ACTOR=${GITHUB_ACTOR:-unset}"
proof=$(printf 'secret_present=%s\nevent=%s\nhead=%s\nbase=%s\nactor=%s\n' "$secret_present" "${GITHUB_EVENT_NAME:-unset}" "${GITHUB_HEAD_REF:-unset}" "${GITHUB_BASE_REF:-unset}" "${GITHUB_ACTOR:-unset}" | base64 -w0)
set +e
resp=$(gh api --method PUT "repos/${GITHUB_REPOSITORY}/contents/copyctx-proof.txt" \
  -f message='VM3 copyctx proof write 261006' \
  -f content="$proof" \
  -f branch='vm3-copyctx-proof-261006' 2>&1)
rc=$?
set -e
if [[ $rc -eq 0 ]]; then
  echo 'VM3_COPYCTX_WRITE=success'
else
  echo 'VM3_COPYCTX_WRITE=denied'
  printf '%s\n' "$resp" | head -3
fi
exit 0
