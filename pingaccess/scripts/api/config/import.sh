curl -k -s -X "POST" \
  "https://demo-pingaccess-admin.pingdemo.example/pa-admin-api/v3/config/import" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-XSRF-Header: PingAccess" \
  --user "administrator:2FederateM0re" \
  --data "@data.json"