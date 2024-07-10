curl -k -s -X "GET" \
  "https://demo-pingaccess-admin.pingdemo.example/pa-admin-api/v3/config/export" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-XSRF-Header: PingAccess" \
  --user "administrator:2FederateM0re" | jq -r > data.json

kubectl delete configmap pingaccess-data
kubectl create configmap pingaccess-data --from-file=data.json
