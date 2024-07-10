curl -k -s -X "GET" \
  "https://demo-pingfederate-admin.pingdemo.example/pf-admin-api/v1/bulk/export" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-XSRF-Header: PingFederate" \
  --user "administrator:2FederateM0re" | jq -r > data.json

kubectl delete configmap pingfederate-data
kubectl create configmap pingfederate-data --from-file=data.json
