#!/bin/bash -e

# Create or rotate certificates and passwords/preshared keys
# in the $VAULT_HASH_KEYCERT and $VAULT_HASH_PASSWORD vault
# hashes.  $SYSTEM_DOMAIN is required for certificate generation.

chmod +x omg-cli/omg-linux

omg-cli/omg-linux register-plugin \
  -type product \
  -pluginpath omg-product-bundle/$PRODUCT_PLUGIN

omg-cli/omg-linux deploy-product \
  --bosh-url $(vault read -field=bosh-url $VAULT_HASH_IP) \
  --bosh-port $(vault read -field=bosh-port $VAULT_HASH_IP) \
  --bosh-user $(vault read -field=bosh-user $VAULT_HASH_IP) \
  --bosh-pass $(vault read -field=bosh-pass $VAULT_HASH_IP) \
  --print-manifest \
  --ssl-ignore \
  $PRODUCT_PLUGIN \
  --infer-from-cloud \
  --stemcell-version $STEMCELL_VERSION \
  --vault-active \
  --vault-domain $VAULT_ADDR \
  --vault-hash-ert $VAULT_HASH_ERT_PASSWORD \
  --vault-hash-ip $VAULT_HASH_IP \
  --vault-hash-mysql-secret $VAULT_HASH_PASSWORD \
  --vault-rotate \
  --vault-token $VAULT_TOKEN > throw-away-manifest.yml

#eof
