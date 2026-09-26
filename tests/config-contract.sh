#!/usr/bin/env bash
# Config contract: a Python application runs on the runtime base.
#
# A child image is built FROM the local image with `main.py` in `/app`, and a
# second one names another script with `CMD`, the way the README tells a user
# to do it. The script imports standard modules that load shared libraries, so
# a library missing from the image fails the test.
#
# Usage: tests/config-contract.sh IMAGE

set -uo pipefail

IMAGE="${1:?usage: tests/config-contract.sh IMAGE}"
CHILD="${IMAGE%%:*}-config-contract-child"
CONTEXT=$(mktemp -d)
trap 'rm -rf "${CONTEXT}"; docker image rm -f "${CHILD}" "${CHILD}-cmd" > /dev/null 2>&1' EXIT

PASS=0
FAIL=0
declare -a FAILED_NAMES

_pass() { PASS=$((PASS + 1)); echo "  PASS  $1"; }
_fail() { FAIL=$((FAIL + 1)); FAILED_NAMES+=("$1"); echo "  FAIL  $1: $2"; }

echo "==> Config contract: Python runtime base"

if ! docker image inspect "${IMAGE}" > /dev/null 2>&1; then
    _fail "${IMAGE}_image_exists" "image not built — run 'npm run build' first"
else
    cat > "${CONTEXT}/main.py" <<'EOF'
import getpass, json, os, ssl, sqlite3, hashlib, zlib, ctypes
sqlite3.connect(':memory:').execute('select 1')
print(json.dumps({'user': getpass.getuser(), 'cwd': os.getcwd(), 'ssl': ssl.OPENSSL_VERSION.split()[0], 'script': 'main'}))
EOF
    sed "s/'main'/'other'/" "${CONTEXT}/main.py" > "${CONTEXT}/other.py"
    printf 'FROM %s\nCOPY main.py other.py /app/\n' "${IMAGE}" > "${CONTEXT}/Dockerfile"
    printf 'FROM %s\nCOPY main.py other.py /app/\nCMD ["other.py"]\n' "${IMAGE}" > "${CONTEXT}/Dockerfile.cmd"

    if docker build --quiet -t "${CHILD}" "${CONTEXT}" > /dev/null 2>&1; then
        OUT=$(docker run --rm --pull=never "${CHILD}" 2>&1)
        if [[ "${OUT}" == *'"script": "main"'* ]]; then _pass "default_main_py_runs"; else _fail "default_main_py_runs" "${OUT}"; fi
        if [[ "${OUT}" == *'"ssl": "OpenSSL"'* ]]; then _pass "shared_libraries_present"; else _fail "shared_libraries_present" "${OUT}"; fi
        if [[ "${OUT}" == *'"user": "somebody"'* ]]; then _pass "runs_as_somebody"; else _fail "runs_as_somebody" "${OUT}"; fi
        if [[ "${OUT}" == *'"cwd": "/app"'* ]]; then _pass "workdir_app"; else _fail "workdir_app" "${OUT}"; fi
    else
        _fail "default_main_py_runs" "child image does not build"
    fi

    if docker build --quiet -t "${CHILD}-cmd" -f "${CONTEXT}/Dockerfile.cmd" "${CONTEXT}" > /dev/null 2>&1; then
        OUT=$(docker run --rm --pull=never "${CHILD}-cmd" 2>&1)
        if [[ "${OUT}" == *'"script": "other"'* ]]; then _pass "cmd_override_runs"; else _fail "cmd_override_runs" "${OUT}"; fi
    else
        _fail "cmd_override_runs" "child image with CMD does not build"
    fi
fi

echo ""
echo "==> Config contract results: ${PASS} passed, ${FAIL} failed"
if [[ ${FAIL} -gt 0 ]]; then
    echo "==> Failed contracts: ${FAILED_NAMES[*]}"
    exit 1
fi
