#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd "${SCRIPT_DIR}/../"
PROJECT_NAME="$(basename ${PWD})"
PROJECT_NAME="${PROJECT_NAME:-NordVPN-Wireguard-QR}"
cd ..
ARCHIVE_FILE="${PROJECT_NAME}/dist/${PROJECT_NAME}"
[ -d "${PROJECT_NAME}/dist" ] || mkdir "${PROJECT_NAME}/dist"

set -x
tar --exclude=".DS_Store" --exclude="${PROJECT_NAME}/.git" --exclude="${PROJECT_NAME}/.wireguard" --exclude="${PROJECT_NAME}/data" --exclude="/**/*.tgz" --exclude="/**/*.zip" -czvf "foo.tgz" ${PROJECT_NAME}
zip -r - "${PROJECT_NAME}" -x "/**/.DS_Store" -x "${PROJECT_NAME}/.wireguard/*" -x "${PROJECT_NAME}/data/*" -x "${PROJECT_NAME}/dist/*" -x "${PROJECT_NAME}/.git/*" >"${ARCHIVE_FILE}.zip"
