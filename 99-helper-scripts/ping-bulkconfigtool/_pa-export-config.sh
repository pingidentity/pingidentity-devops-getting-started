function prop {
    grep "${1}" env.properties|cut -d'=' -f2
}

echo "Creating output folder..."
mkdir -p out/pingaccess

echo "Downloading config from https://localhost:9000..."
curl -X GET --basic -u $(prop 'PINGACCESS_ADMIN_CREDENTIALS') --header 'Content-Type: application/json' --header 'X-XSRF-Header: PingAccess' $(prop 'PINGACCESS_ADMIN_BASEURL')/pa-admin-api/v3/config/export --insecure > out/pa-export.json

echo "Creating/modifying out/pingaccess/pa.env and out/pingaccess/data.json.subst..."
java -jar ping-bulkexport-tools-project/target/ping-bulkexport-tools-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./in/pa-config.json ./out/pa-export.json ./out/pingaccess/pa.env ./out/pingaccess/data.json.subst > ./out/pingaccess/export-convert.log
