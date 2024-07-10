curl -k -s -X "POST" \
  "https://demo-pingfederate-admin.pingdemo.example/pf-admin-api/v1/bulk/import" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-XSRF-Header: PingFederate" \
  --user "administrator:2FederateM0re" \
  --data "@data.json"| jq