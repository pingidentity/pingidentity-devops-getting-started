#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIND_CONFIG="${KIND_CONFIG:-${SCRIPT_DIR}/kind.yaml}"
KIND_NAME="${KIND_NAME:-ping}"
if kind get clusters | grep -qx "${KIND_NAME}"; then
  kind delete cluster --name "${KIND_NAME}"
fi

kind create cluster --name "${KIND_NAME}" --config "${KIND_CONFIG}"
