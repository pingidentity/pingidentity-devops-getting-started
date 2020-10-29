function prop {
    grep "${1}" env.properties|cut -d'=' -f2
}

echo "Creating output folder..."
mkdir -p out/pingfederate

echo "Downloading config from https://localhost:9999..."
curl -X GET --basic -u $(prop 'PINGFEDERATE_ADMIN_CREDENTIALS') --header 'Content-Type: application/json' --header 'X-XSRF-Header: PingFederate' $(prop 'PINGFEDERATE_ADMIN_BASEURL')/pf-admin-api/v1/bulk/export --insecure > ./out/pf-export.json

echo "Creating/modifying ./out/pingfederate/pf.env and ./out/pingfederate/requestBody.json.subst..."
java -jar ping-bulkexport-tools-project/target/ping-bulkexport-tools-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./in/pf-config.json ./out/pf-export.json ./out/pingfederate/pf.env ./out/pingfederate/requestBody.json.subst > ./out/pingfederate/export-convert.log
