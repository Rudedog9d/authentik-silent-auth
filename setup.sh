#!/usr/bin/env bash
set -e

curl -sL https://goauthentik.io/docker-compose.yml -o docker-compose.authentik.yml

declare -A env
env["PG_PASS"]=`openssl rand -base64 36`
env["AUTHENTIK_SECRET_KEY"]=`openssl rand -base64 36`
env["AUTHENTIK_ERROR_REPORTING_ENABLED"]="true"
env["AUTHENTIK_BOOTSTRAP_PASSWORD"]="admin"
env["AUTHENTIK_BOOTSTRAP_TOKEN"]=`openssl rand -base64 36`
env["AUTHENTIK_BOOTSTRAP_EMAIL"]="admin@example.com"
env["AUTHENTIK_TOKEN"]=${env["AUTHENTIK_BOOTSTRAP_TOKEN"]}
env["AUTHENTIK_INSECURE"]="true"
env["AUTHENTIK_URL"]="https://auth.local.malteksolutions.com"
env["BASE_DOMAIN"]="local.malteksolutions.com"

for K in ${!env[@]}
do
    if [[ ! `grep $K .env 2> /dev/null` ]]; then
        echo "$K=${env[$K]}" >> .env
    fi
done

docker compose up -d --build
terraform init
set -a
source .env
set +a

echo "Waiting for boot"
while [[ `curl -skL "$AUTHENTIK_URL/api/v3/admin/version/" -w "%{http_code}" -o /dev/null -H "Authorization: Bearer $AUTHENTIK_BOOTSTRAP_TOKEN"` -ne 200 ]];
do
    sleep 1
done

terraform apply -auto-approve