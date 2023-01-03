#!/bin/bash
cd "$( dirname "${0}" )"
THIS="$( basename "${0}" )"
THIS_DIR=`pwd`

CURR_DATE=$(date +%Y%m%d)

#
# Usage printing function
#
usage ()
{
cat <<END_USAGE
Usage: $0 {github|local}
    where {options} include:

    github
        Test the motd.json file from github
    local
        Test the motd.json file from local directory

    One of these options are required

END_USAGE
exit 99
}

while ! test -z "${1}" ; do
    case "${1}" in
        github)
            shift

            MOTD_FILE="/tmp/motd.json.$$"
            MOTD_URL="https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/motd/motd.json"

            motdCurlResult=$(curl -G -o "${MOTD_FILE}" -w '%{http_code}' \
                "${MOTD_URL}" \
                2> /dev/null)

            if test $motdCurlResult -eq 200 ; then
                echo "Successfully downloaded motd.json from Github"
            else
                echo "ERROR: Unable to download motd.json from Github "
                echo "  URL: ${MOTD_URL}"
                exit 1
            fi
            MOTD_SOURCE="gitlab"
            ;;

        local)
            shift

            MOTD_FILE="${THIS_DIR}/motd.json"
            MOTD_SOURCE="local"
            ;;
        *)
            echo "Unrecognized option"
            usage
            ;;
    esac
    shift
done

test -z ${MOTD_SOURCE} && usage


JQ_EXPR=".[] | select(.validFrom <= ${CURR_DATE} and .validTo >= ${CURR_DATE}) |
               \"\n---- SUBJECT: \" + .subject + \"\n\" +
                         (.message | join(\"\n\")) +
               \"\n\""

echo "
################################################################################
#                         Testing MOTD
#         SOURCE = ${MOTD_SOURCE}
#      MOTD_FILE = ${MOTD_FILE}
#   CURRENT_DATE = ${CURR_DATE}
#        JQ_EXPR = ${JQ_EXPR}
################################################################################"

JQ_EXPR=".[] | select(.validFrom <= ${CURR_DATE} and .validTo >= ${CURR_DATE}) |
               \"\n---- SUBJECT: \" + .subject + \"\n\" +
                         (.message | join(\"\n\")) +
               \"\n\""

for category in "devops" "pingaccess" "pingdatasync" "pingdirectory" "pingdirectoryproxy" "pingfederate" ;
do
    echo "
################################################################################
#                         Testing '${category}' Category
################################################################################"

    cat ${MOTD_FILE} | \
            jq -r ".${category} | $JQ_EXPR"
done
