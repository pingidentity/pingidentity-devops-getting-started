#!/usr/bin/env sh
TOOL_NAME=$( basename "${0}" )
cd "$( dirname "${0}" )" || exit 1

availableProducts="pingfederate pingaccess pingdirectory pingdatasync"
containerInstancePath="/opt/out/instance"

##########################################################################################
usage ()
{
	if ! test -z "${1}" ; then
       echo "-------------------------------------------------------------------------"
	   echo "Error: ${1}"
       echo "-------------------------------------------------------------------------"
	fi

	cat <<END_USAGE1
Usage: ${TOOL_NAME} {options}
    where {options} include:
       *-p, --product {product}
END_USAGE1

	for prodName in ${availableProducts}; do
	    echo "                            ${prodName}"
	done
    
	cat <<END_USAGE2
        -t : build from a template
        -c, --container {docker container}: build from a container
        -i, --instance {path}:  build from a local instance

        -o, --ouptut-dir {path}: Directory to create new server-profile
                                 Default: /tmp/server-profiile-{pid}

        -d : Turn on script debugging
END_USAGE2
	exit 77
}

##########################################################################################
# Build PingFederate
##########################################################################################
buildPingFederateServerProfile()
{
    echo "Building PingFederate Server Profile"
    
    mkdir -p "${outputDir}/bin"
    mkdir -p "${outputDir}/etc"
    mkdir -p "${outputDir}/server/default/conf"
    mkdir -p "${outputDir}/server/default/data/drop-in-deployer"

    echo "Getting..."
    echo "    bin files (probably only need .properties and .xml files)........"
    docker cp "${dockerContainerId}:${containerInstancePath}/bin" "${outputDir}"

    echo "    etc files..."
    docker cp "${dockerContainerId}:${containerInstancePath}/etc" "${outputDir}"

    echo "    conf files (a ton of stuff, templates, l18n message files........"
    docker cp "${dockerContainerId}:${containerInstancePath}/server/default/conf" "${outputDir}/server/default"

    echo "    latest data.zip"
    lastestDataArchive=$( docker exec "${dockerContainerId}" ls -Art "${containerInstancePath}/server/default/data/archive"  | tail -1 )
    echo "Getting ${lastestDataArchive}"
    docker cp "${dockerContainerId}:${containerInstancePath}/server/default/data/archive/${lastestDataArchive}" "${outputDir}/server/default/data/drop-in-deployer/data.zip"

    # BELOW REPRESENTS SOME IDEAS TO BUILD UP ON CONTAINER FIRST
    # docker cp local-build.sh  up to the container
    # docker exec -it ${containerId} /opt/build-server-profile
    # docker cp ${dockerContainerId}} /opt/scripts/server-profile /tmp/.

}

##########################################################################################
# Build PingAccess
##########################################################################################
buildPingAccessServerProfile()
{
    echo "Building PingAccess Server Profile"
    echo "Yet to be implemented"

    # An option if curling from external
    # curl -k -u administrator:2FederateM0re -H "Content-type: application/json" https://lic.pingaccess.devops.gte:9000/pa-admin-api/v3/config/export > output.json
    # docker cp ${dockerContainerId}:/opt/out/instance/data/archive/latest.data.zip /tmp
    # unzip -d "${serverPofilePath}" /tmp/latest.data.zip
    # Potential Templates
    # log4j
    # run.properties

}

##########################################################################################
# Build PingDirectory
##########################################################################################
buildPingDirectoryServerProfile()
{
    echo "Building PingDirectory Server Profile"
    echo "Yet to be implemented"
}

##########################################################################################
# Build PingAccess
##########################################################################################
buildPingDataSyncServerProfile()
{
    echo "Building PingDataSync Server Profile"
    echo "Yet to be implemented"
}

##########################################################################################
outputDir="/tmp/server-profile-$$"
product=""
dockerContainerId=""
instancePath=""
while ! test -z "${1}" ; do
    case "${1}" in
        -p|--product)
			shift
			test -z "${1}" && usage "Product argument missing"
			
			# lowercase the argument value (the product name )
			product=$( echo ${1} | tr [A-Z] [a-z] )

	        for prodName in ${availableProducts}; do
	            if test "${product}" = "${prodName}" ; then
				    foundProduct=true
				fi
	        done
			;;
		-c|--container)
			shift
			test -z "${1}" && usage "Container id/name missing"
			containerId=${1}
            dockerContainerId=$( docker ps -q -f name=${containerId} )
            test ! -z "${dockerContainerId}" || dockerContainerId=$( docker ps -q -f id=${containerId} )
            test ! -z "${dockerContainerId}" || usage "Unable to find locally running docker container '${containerId}'"
            echo "Using container: ${dockerContainerId}"
			;;
		-i|--instance)
			shift
			test -z "${1}" && usage "Instance path missing"
			instancePath=${1}
            test -d "${instancePath}" || usage "Path '${instancePath}' not found"
			;;
		-o|--output-dir)
			shift
			test -z "${1}" && usage "output-dir path missing"
			outputDir=${1}
            test -d "${outputDir}" && usage "Output Directory '${outputDir}' exists.  Please provide new path"
            ;;
		-d|--debug)
			set -x
			;;
		*)
			usage
			;;
	esac
    shift
done

# Check combination of options
test ! -z "${dockerContainerId}" && test ! -z "${instancePath}" && usage "Only a container or instance can be used"
test -z "${product}" && usage "Product name required"

echo "
###############################################################################################
# Building Server Profile
###############################################################################################
#
#      Product: ${product}
#    Container: ${containerId}
#   Output Dir: ${outputDir}
#
###############################################################################################

"
mkdir -p "${outputDir}"
			
case ${product} in
    "pingfederate")
       buildPingFederateServerProfile
       ;;
    "pingaccess")
       buildPingAccessServerProfile
       ;;
    "pingdirectory")
       buildPingDirectoryServerProfile
       ;;
    "pingdatasync")
       buildPingDataSyncServerProfile
       ;;
esac


exit



#!/usr/bin/env sh
if test -z "${1}" ; then
    echo the first argument must be a container id
    exit 1
fi

if test -z "${2}" ; then
    echo "The second argument must the path to the server profile"
    exit 2
fi

if ! test -d "${2}" ; then
  echo the path to the server profile does not exist
  exit 3
fi

if ! test $(basename "${2}") = "instance" ; then
    echo "the server profile path should end with 'instance' (i.e. </path/to/pa-server-profile>/instance)"
    exit 4
fi
containerId="${1}"
serverPofilePath="${2}"
