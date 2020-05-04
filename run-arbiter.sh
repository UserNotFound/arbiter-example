#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

SSL_BUNDLE_FILE="${SSL_DIRECTORY}/mongodb.pem"
ARB_PATH="/var/lib/mongodb/arb"
CLUSTER_KEY_FILE="/.aptible-keyfile"

function mongo_initialize_certs () {
  local ssl_cert_file="${SSL_DIRECTORY}/mongodb.crt"
  local ssl_key_file="${SSL_DIRECTORY}/mongodb.key"
  mkdir -p "$SSL_DIRECTORY"

  echo "Autogenerating certificate."
  SUBJ="/C=US/ST=New York/L=New York/O=Example/CN=mongodb.example.com"
  OPTS="req -nodes -new -x509 -sha256"
  openssl $OPTS -subj "$SUBJ" -keyout "$ssl_key_file" -out "$ssl_cert_file" 2> /dev/null

  cat "$ssl_key_file" "$ssl_cert_file" > "$SSL_BUNDLE_FILE"
}

mkdir "$ARB_PATH"
mongo_initialize_certs

echo "${CLUSTER_KEY}" > "$CLUSTER_KEY_FILE"
chmod 600 "$CLUSTER_KEY_FILE"


exec mongod --port 27017 \
            --dbpath "$ARB_PATH" \
            --bind_ip 0.0.0.0 \
            --sslMode "requireSSL" \
            --sslPEMKeyFile "$SSL_BUNDLE_FILE" \
            --replSet "$RS_NAME" \
            --keyFile "$CLUSTER_KEY_FILE"
