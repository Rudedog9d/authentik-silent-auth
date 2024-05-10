#!/usr/bin/env bash
set -e

curl -sL https://goauthentik.io/docker-compose.yml -o docker-compose.yml

declare -A env
env["PG_PASS"]=`openssl rand -base64 36`
env["AUTHENTIK_SECRET_KEY"]=`openssl rand -base64 36`
env["AUTHENTIK_ERROR_REPORTING_ENABLED"]="true"
env["COMPOSE_PORT_HTTP"]="80"
env["COMPOSE_PORT_HTTPS"]="443"
env["AUTHENTIK_BOOTSTRAP_PASSWORD"]="admin"
env["AUTHENTIK_BOOTSTRAP_TOKEN"]=`openssl rand -base64 36`
env["AUTHENTIK_BOOTSTRAP_EMAIL"]="admin@example.com"
env["AUTHENTIK_TOKEN"]=${env["AUTHENTIK_BOOTSTRAP_TOKEN"]}
env["AUTHENTIK_INSECURE"]="true"
env["AUTHENTIK_URL"]="https://auth.local.malteksolutions.com"

for K in ${!env[@]}
do
    if [[ ! `grep $K .env 2> /dev/null` ]]; then
        echo "export $K=${env[$K]}" >> .env
    fi
done

docker compose up -d --build
terraform init
source .env

echo "Waiting for boot"
while [[ `curl -skL "https://127.0.0.1/api/v3/admin/version/" -w "%{http_code}" -o /dev/null -H "Authorization: Bearer $AUTHENTIK_BOOTSTRAP_TOKEN"` -ne 200 ]];
do
    sleep 1
done

terraform apply -auto-approve