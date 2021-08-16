#!/bin/bash

# Configuration
_EMAIL=user@email.com
_API_TOKEN=XXXXXXXXXXXXX
# Complete the array below with all domain|subdomain entries you want to update at Cloudflare
_DOMAIN_SUBDOMAIN=(
    'domain.tld|subdomain.domain.tld'
)

# Auto detect wan address
_NEW_IP=$(curl api.ipify.org)

for _domsub in ${_DOMAIN_SUBDOMAIN[*]};
    do
        IFS='|' read -r -a _ds <<< "$_domsub"

        { #iniciar silenciamento de outputs no terminal
            _zone_id=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?name=${_ds[0]}" \
                -H "X-Auth-Email: $_EMAIL" \
                -H "X-Auth-Key: $_API_TOKEN" \
                -H "Content-Type: application/json" | jq -r '.result[].id')

            _id_dns_record=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$_zone_id/dns_records?type=A&name=${_ds[1]}" \
                    -H "X-Auth-Email: $_EMAIL" \
                    -H "X-Auth-Key: $_API_TOKEN" \
                    -H "Content-Type: application/json" | jq -r '.result[].id')

            curl -X PUT "https://api.cloudflare.com/client/v4/zones/$_zone_id/dns_records/$_id_dns_record" \
                    -H "X-Auth-Email: $_EMAIL" \
                    -H "X-Auth-Key: $_API_TOKEN" \
                    -H "Content-Type: application/json" \
                    --data '{"type":"A","name":"'"${_ds[1]}"'","content":"'"$_NEW_IP"'","ttl":1,"proxied":true}'
        } &> /dev/null #finalizar silenciamento
        
        echo "Subdominio atualizado: ${_ds[1]}"
    done;
