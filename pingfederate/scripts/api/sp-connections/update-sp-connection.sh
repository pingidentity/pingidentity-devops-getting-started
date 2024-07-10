curl -k -s -X "PUT" \
  "https://demo-pingfederate-admin.pingdemo.example/pf-admin-api/v1/idp/spConnections/${1}" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-XSRF-Header: PingFederate" \
  --user "administrator:2FederateM0re" \
  -d "@${1}.json" | jq