#!/bin/bash

set -Ceo pipefail

WORKSPACE="$(terraform workspace show)"

# shellcheck disable=SC2154
terraform init --backend-config="bucket=${backend_bucket}" --backend-config="key=${WORKSPACE}/${backend_key_basename}"