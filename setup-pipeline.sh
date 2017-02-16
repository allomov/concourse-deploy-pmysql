#!/usr/bin/env bash
set -ex

export VAULT_HASH=secret/$PRODUCT_NAME-$FOUNDATION_NAME-props
export CF_VAULT_PASSWORD_HASH=secret/cf-$FOUNDATION_NAME-password
export CF_VAULT_PROPS_HASH=secret/cf-$FOUNDATION_NAME-props

echo "requires files (rootCA.pem, director.pwd, deployment-props.json)"
vault write ${VAULT_HASH} \
  bosh-cacert=@$BOSH_CA_CERT \
  bosh-url=https://$BOSH_ENVIRONMENT \
  bosh-user=admin \
  bosh-pass=$BOSH_CLIENT_SECRET \
  bosh-client-secret=$BOSH_CLIENT_SECRET \
  bosh-client-id=director \
  bosh-port="25555" \
  vm-type="medium" \
  disk-type="large" \
  base-domain=$(vault read --field=base-domain $CF_VAULT_PROPS_HASH) \
  admin-password=$(vault read --field=admin-password $CF_VAULT_PASSWORD_HASH) \
  notifications-client-secret=$(vault read --field=notifications-client-secret $CF_VAULT_PASSWORD_HASH) \
  uaa-admin-secret=$(vault read --field=uaa-admin-secret $CF_VAULT_PASSWORD_HASH) \
  nats-pass=$(vault read --field=nats-pass $CF_VAULT_PASSWORD_HASH) \
  nats-machine-ip=$(vault read --field=nats-machine-ip $CF_VAULT_PROPS_HASH) \
  @deployment-props.json \

vault read --format=json secret/$PRODUCT_NAME-$FOUNDATION_NAME-props | jq .data > temp/vault-values.json

j2y temp/vault-values.json > temp/vault-values.yml

fly -t $CONCOURSE_TARGET login -c $CONCOURSE_URI -u $CONCOURSE_USER -p $CONCOURSE_PASSWORD

fly -t $CONCOURSE_TARGET set-pipeline -p $PRODUCT_NAME-$FOUNDATION_NAME \
              --config="ci/pmysql-pipeline.yml" \
              --var="vault-address=$VAULT_ADDR" \
              --var="vault-token=$VAULT_TOKEN" \
              --var="foundation-name=$FOUNDATION_NAME" \
              --var="pipeline-repo=$PIPELINE_REPO" \
              --var="pipeline-repo-branch=$PIPELINE_REPO_BRANCH" \
              --var="pipeline-repo-private-key=$PIPELINE_REPO_PRIVATE_KEY_PATH" \
              --var="product-name=$PRODUCT_NAME" \
              --var="concourse-url=$CONCOURSE_URI" \
              --var="concourse-user=$CONCOURSE_USER" \
              --var="concourse-pass=$CONCOURSE_PASSWORD" \
              --var="deployment-name=$PRODUCT_NAME-$FOUNDATION_NAME" \
              --var="vault_addr=$VAULT_ADDR" \
              --var="vault_token=$VAULT_TOKEN" \
              --var="vault_hash_hostvars=secret/$PRODUCT_NAME-$FOUNDATION_NAME-hostvars" \
              --var="vault_hash_ip=secret/$PRODUCT_NAME-$FOUNDATION_NAME-props" \
              --var="vault_hash_keycert=secret/$PRODUCT_NAME-$FOUNDATION_NAME-keycert" \
              --var="vault_hash_misc=secret/$PRODUCT_NAME-$FOUNDATION_NAME-props" \
              --var="vault_hash_password=secret/$PRODUCT_NAME-$FOUNDATION_NAME-password" \
              --var="vault_hash_ert_password=secret/cf-$FOUNDATION_NAME-password" \
              --var="vault_hash_ert_ip=secret/cf-$FOUNDATION_NAME-props" \
              --load-vars-from pipeline-defaults.yml \
              --load-vars-from temp/vault-values.yml 


fly -t $CONCOURSE_TARGET unpause-pipeline -p $PRODUCT_NAME-$FOUNDATION_NAME


