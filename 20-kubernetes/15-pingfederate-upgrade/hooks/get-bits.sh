#!/usr/bin/env sh
#
# Ping Identity DevOps - Docker Build Hooks
#
test "${VERBOSE}" = "true" && set -x
cd "$(dirname "${0}")" || exit 97

##########################################################################################
usage() {
    if test -n "${1}"; then
        echo "Error: ${1}"
    fi

    cat << END_USAGE1
Usage: docker run pingidentity/pingdownloader {options}

This tool can be used to download either product binaries (.zip) files or
product evaluation licenses (.lic).  By default, the product binaries will
be downloaded.  If the -l option is provided then only a license will be
downloaded.  If a license is pulled, a Ping DevOps Key/User is required.

Options include:
    *-p, --product {product-name}   The name of the product bits/license to download
    -v, --version {version-num}     The version of the product bits/license to download.
                                    by default, the downloader will pull the
                                    latest version
    -u, --devops-user {devops-user} Your Ping DevOps Username
                                    Alternately, you may pass PING_IDENTITY_DEVOPS_USER
                                    environment variable
    -k, --devops-key {devops-key}   Your Ping DevOps Key
                                    Alternately, you may pass PING_IDENTITY_DEVOPS_KEY
                                    environment variable
    -a, --devops-app {app-name}     Your App Name
    -r, --repository                The URL of the repository to use to get the bits
    -m, --metadata-file             The file name with the repository metadata

For product downloads:
    -c, --conserve-name             Use this option to conserve the original
                                    file name by default, the downloader will
                                    rename the file product.zip or the file name
                                    provided
    -f, --file-name                 file name to use for the product zip file
    -n, --dry-run                   This will cause the URL to be displayed
                                    but the the bits not to be downloaded
    --verify-gpg-signature          Verify the GPG signature. The bits are removed in
                                    the event verification fails
    --snapshot                      Get snapshot build (Ping Internal)
    --snapshot-url                  Get snapshot build from URL (Ping Internal)


For license downloads:
    *-l, --license                   Download a license file

Where {product-name} is one of:
END_USAGE1

    for prodName in ${availableProducts}; do
        echo "   ${prodName}"
    done

    cat << END_USAGE2

Example:

    Pull the latest version of PingDirectory down to a product.zip file

        docker run pingidentity/pingdownloader -p pingdirectory

    Pull the 9.3 version of PingFederate eval license file down to a product.lic

        docker run pingidentity/pingdownloader -p pingfederate -v 9.3 -l -u john@example.com \\
                    -k 94019ea5-ecca-49a4-8962-990130df3815 -a pingdownloader

END_USAGE2
    exit 77
}

FONT_RED="$(printf '\033[0;31m')"
FONT_GREEN="$(printf '\033[0;32m')"
FONT_NORMAL="$(printf '\033[0m')"
#CHAR_CHECKMARK="$( printf '\xE2\x9C\x94' )"
#CHAR_CROSSMARK="$( printf '\xE2\x9D\x8C' )"

################################################################################
# Echo message in red color
################################################################################
echo_red() {
    # test "$( uname )" = "Darwin" && _echoOpts="-e"
    # echo ${_echoOpts} "${FONT_RED}$*${FONT_NORMAL}"
    printf "%s%s%s\n" "${FONT_RED}" "${*}" "${FONT_NORMAL}"
}

################################################################################
# Echo message in green color
################################################################################
echo_green() {
    # test "$( uname )" = "Darwin" && _echoOpts="-e"
    # echo ${_echoOpts} "${FONT_GREEN}$*${FONT_NORMAL}"
    printf "%s%s%s\n" "${FONT_GREEN}" "${*}" "${FONT_NORMAL}"
}

##########################################################################################
# Get the properties used to provide the following items to this script:
#
#    Product Names - lowercase names used to request specific products (i.e. pingaccess)
#
#    Product Mappings - mapping from product name to filename used on server
#                       i.e. pingdirectory --> PingDirectory
#
#    Product URL - URL used to download the filename.  In most cases, a defaultURL is
#                  provided.  If a specific location is required, then a product URL
#                  is specified (i.e. ldapsdkURL --> https://somewhereelse.com/ldapsdk...)
#
#    Product Latest Version - If no specific version is requested, the latest version will
#                             be retrieved (i.e. pingdirectoryLatestVersion=7.2.0.1)
##########################################################################################
getProps() {
    _tmpApp=${devopsApp}
    devopsApp="pingdownloader"

    _returnCode=99
    _retries=4
    while test ${_retries} -gt 0; do
        _retries=$((_retries - 1))
        _curl -H "devops-purpose: get-metadata" "${repositoryURL}${metadataFile}" -o "${outputProps}"
        _returnCode=${?}
        test ${_returnCode} -eq 0 && break
    done
    if test ${_returnCode} -ne 0; then
        usage "Unable to get bits metadata. Network Issue?"
    fi

    availableProducts=$(jq -r '.products[].name' "${outputProps}")
    devopsApp=${_tmpApp}
}

##########################################################################################
# Based on the productLatestVersion variable, evaluate the version from the
# properties file
# Example: ...LatestVersion=1.0.0.0
##########################################################################################
getProductVersion() {
    latestVersion=$(jq -r ".products[] | select(.name==\"${product}\").latestVersion" "${outputProps}")

    if test -z "${version}" || test "${version}" = "latest"; then
        version=${latestVersion}
        if test "${version}" = "null"; then
            usage "Unable to determine latest version for ${product}"
        else
            licenseVersion=$(echo "${version}" | cut -d. -f1,2)
        fi
    fi

    test "${version}" = "${latestVersion}" && latestStr="(latest)"
}

##########################################################################################
# Based on the productMapping variable, evaluate the mapping from the
# properties file  Note that there needs to be 2 consecutive evals
# since there may be a variable encoding in the variable
# Example: ...Mapping=productName-${version}.zip
##########################################################################################
getProductFile() {
    prodFile=$(jq -r ".products[] | select(.name==\"${product}\").mapping" "${outputProps}")
    prodFile=$(eval echo "$prodFile")
    test "${prodFile}" = "null" && usage "Unable to determine download file for ${product}"
}

##########################################################################################
# Based on the productURL variable, evaluate the URL from the
# properties file  Note that there needs to be 2 consecutive evals
# since there may be a variable encoding in the variable
# Example: ...URL=https://.../${version}/
##########################################################################################
getProductURL() {
    defaultURL=$(jq -r '.defaultURL' "${outputProps}")

    prodURL=$(jq -r ".products[] | select(.name==\"${product}\").url" "${outputProps}")

    prodURL=$(eval echo "$prodURL")

    # If a productURL wasn't provide, we should use the defaultDownloadURL
    test "${prodURL}" = "null" && prodURL=${defaultURL}

    test "${prodURL}" = "null" && usage "Unable to determine download URL for ${product}"
}

getProductLicenseFile() {
    licenseFile=$(jq -r ".products[] | select(.name==\"${product}\").licenseFile" "${outputProps}")
    if test "${licenseFile}" = "null"; then
        licenseFile=""
    fi
    licenseFile=$(eval echo "${licenseFile}")
    # test "${licenseFile}" = "null" && usage "Unable to determine license file for ${product}"
}

getGPGKeyServer() {
    jq -r ".gpg.server" "${outputProps}"
}

getGPGKeyID() {
    jq -r ".gpg.key" "${outputProps}"
}

getGPGKeyFile() {
    jq -r ".gpg.file" "${outputProps}"
}

saveOutcome() {
    mv "${output}" download-outcome.html
}

cleanup() {
    test -z "${dryRun}" && rm -f "${outputProps}"
    test -d "${TMP_VS}" && rm -rf "${TMP_VS}"
}

_curl() {
    _httpResultCode=$(
        curl \
            --get \
            --silent \
            --show-error \
            --write-out '%{http_code}' \
            --location \
            --connect-timeout 2 \
            --retry 6 \
            --retry-max-time 30 \
            --retry-connrefused \
            --retry-delay 3 \
            --header "devops-user: ${devopsUser}" \
            --header "devops-key: ${devopsKey}" \
            --header "devops-app: ${devopsApp}" \
            "${@}"
    )
    test "${_httpResultCode}" = "200"
    return ${?}
}

download_and_verify() {
    GNUPGHOME="$(mktemp -d)"
    export GNUPGHOME
    TMP_VS="$(mktemp -d)"
    PAYLOAD="${TMP_VS}/payload"
    SIGNATURE="${TMP_VS}/signature"
    KEY="${TMP_VS}/key"
    OBJECT="${1}"
    KEY_SERVER="${2}"
    KEY_ID="${3}"
    DESTINATION="${4}"
    echo "disable-ipv6" >> "${GNUPGHOME}/dirmngr.conf"

    _returnCode=99
    _retries=4
    while test ${_retries} -gt 0; do
        _retries=$((_retries - 1))
        _curl --header "devops-purpose: signature" --output "${SIGNATURE}" "${OBJECT}.asc"
        _returnCode=${?}
        test ${_returnCode} -eq 0 && break
    done
    if test ${_returnCode} -ne 0; then
        echo_red "Downloading the payload signature failed after 4 attempts"
        return 1
    fi

    _returnCode=99
    _retries=4
    while test ${_retries} -gt 0; do
        _retries=$((_retries - 1))
        _curl --header "devops-purpose: payload-signed" --output "${PAYLOAD}" "${OBJECT}"
        _returnCode=${?}
        test ${_returnCode} -eq 0 && break
    done
    if test ${_returnCode} -ne 0; then
        echo_red "Downloading the payload failed"
        return 2
    fi
    #
    # the gpg cli does not natively support retries, forcing us to
    # manually implement retries to fetch the signature from the
    # GPG public key server
    #
    # pass "file" as the key argument to have this function download the file instead
    if test "${KEY_ID}" = "file"; then
        _retries=4
        while test ${_retries} -gt 0; do
            _retries=$((_retries - 1))
            _curl --header "devops-purpose: signature-key" --output "${KEY}" "${KEY_SERVER}"
            _returnCode=${?}
            test ${_returnCode} -eq 0 && break
        done
        if test ${_returnCode} -eq 0; then
            gpg --import "${KEY}" > /dev/null 2> /dev/null
            _returnCode=${?}
            if test ${_returnCode} -ne 0; then
                echo_red "The PGP key file could not be imported"
            fi
        else
            echo_red "The PGP key file could not be downloaded from ${KEY_SERVER} after 4 attempts"
            _returnCode=1
        fi
    else
        _retries=4
        while test ${_retries} -gt 0; do
            _retries=$((_retries - 1))
            gpg --batch --keyserver "${KEY_SERVER}" --recv-keys "${KEY_ID}" > /dev/null 2> /dev/null
            _returnCode=${?}
            test ${_returnCode} -eq 0 && break
        done
    fi

    if test ${_returnCode} -ne 0; then
        echo_red "Obtaining the public key to verify the payload signature failed"
        return ${_returnCode}
    fi

    gpg --batch --verify "${SIGNATURE}" "${PAYLOAD}" > /dev/null 2> /dev/null
    _returnCode=${?}
    if test ${_returnCode} -eq 0; then
        echo_green "The payload signature was successfully verified."
        mv "${PAYLOAD}" "${DESTINATION}"
    else
        echo_red "The payload signature verification failed."
        rm "${PAYLOAD}"
    fi
    gpgconf --kill all > /dev/null 2> /dev/null
    return ${_returnCode}
}

product=""
version=""
# dry run optional
dryRun=""
# Default to the user/key that may have been provided via the devops environment file
devopsUser="${PING_IDENTITY_DEVOPS_USER}"
devopsKey="${PING_IDENTITY_DEVOPS_KEY}"
# default to GTE public repo in S3
repositoryURL="https://bits.pingidentity.com/"
licenseURL="https://license.pingidentity.com/devops/v2/license"
# default to GTE metadata file
metadataFile="gte-bits-repo.json"
# default app name
devopsApp=""
output="product.zip"
while test -n "${1}"; do
    case "${1}" in
        -a | --devops-app)
            shift
            test -z "${1}" && usage "Ping DevOps AppName missing"
            devopsApp="${1}"
            ;;
        -c | --conserve-name)
            conserveName=true
            ;;
        -p | --product)
            shift
            test -z "${1}" && usage "Product argument missing"
            # lowercase the argument value (the product name )
            product=$(echo "${1}" | tr '[:upper:]' '[:lower:]')
            ;;
        -f | --file-name)
            shift
            test -z "${1}" && usage "Missing file name"
            output="${1%.zip}.zip"
            ;;
        -k | --devops-key)
            shift
            test -z "${1}" && usage "Ping DevOps Key missing"
            devopsKey="${1}"
            ;;
        -l | --license)
            pullLicense=true
            ;;
        -m | --metadata-file)
            shift
            test -z "${1}" && usage "Missing metadata file"
            metadataFile="${1}"
            ;;
        -n | --dry-run)
            dryRun="echo"
            ;;
        --snapshot)
            getSnapshot=true
            ;;
        --snapshot-url)
            shift
            test -z "${1}" && usage "Missing snapshot url for provided --snapshot-url flag"
            snapshot_url="${1}"
            ;;
        -r | --repository)
            shift
            test -z "${1}" && usage "Missing repository URL"
            repositoryURL="${1}"
            ;;
        -u | --devops-user)
            shift
            test -z "${1}" && usage "Ping DevOps Username missing"
            devopsUser="${1}"
            ;;
        -v | --version)
            shift
            test -z "${1}" && usage "Product version missing"
            version="${1}"
            licenseVersion=$(echo "${version}" | cut -d. -f1,2)
            ;;
        --verify-gpg-signature)
            verifyGPGSignature=true
            ;;
        *)
            usage
            ;;
    esac
    shift
done
outputProps="/tmp/${metadataFile}"

if test -f "${output}" && test ! ${pullLicense}; then
    echo_green "Using existing file at ${output} without verification."
    exit 0
fi

# If we weren't passed a product option, then error
test -z "${product}" && usage "Option --product {product} required"
test -n "${getSnapshot}" && exec /get-snapshots.sh "${product}" "${snapshot_url}"

test -z "${devopsUser}" && usage "Option --devops-user {devops-user} required for eval license"
test -z "${devopsKey}" && usage "Option --devops-key {devops-key} required for eval license"

# calling getProps populates the list of available products from the metadata file
getProps
for prodName in ${availableProducts}; do
    if test "${product}" = "${prodName}"; then
        foundProduct=true
        break
    fi
done
# If we didn't find the product in the property file, then error
test ${foundProduct} || usage "Invalid product name ${product}"

getProductVersion
getProductFile
getProductURL

exitCode=1

if test ${pullLicense}; then
    case "${product}" in
        pingdirectory | pingdatasync | pingdirectoryproxy | pingdatametrics)
            productShortName="PD"
            ;;
        pingaccess)
            productShortName="PA"
            ;;
        pingdatagovernance)
            productShortName="PG"
            ;;
        pingauthorize)
            productShortName="PingAuthorize"
            ;;
        pingdatagovernancepap)
            productShortName="PG"
            ;;
        pingauthorizepap)
            productShortName="PingAuthorize"
            ;;
        pingfederate)
            productShortName="PF"
            ;;
        pingcentral)
            productShortName="PC"
            ;;
        pingintelligence)
            productShortName="pingintelligence"
            ;;
        *)
            usage "No license files available for $product"
            ;;
    esac

    getProductLicenseFile
    output="product.lic"
    test ${conserveName} && test -n "${licenseFile}" && output=${licenseFile}

    test -z "${devopsApp}" && devopsApp="pingdownloader-license-${product}"
else
    if test "${version%-fsoverride}" != "${version}"; then
        echo_green "FS Override. Short-circuiting download."
        exit 0
    fi
    # Construct the url used to pull the product down
    url="${prodURL}${prodFile}"

    test ${conserveName} && output=${prodFile}
    test -z "${devopsApp}" && devopsApp="pingdownloader-download-${prodFile}"
fi

echo "
######################################################################
# Ping Downloader
#
#          PRODUCT: ${product}
#          VERSION: ${version} ${latestStr}"

if test ${pullLicense}; then
    echo "#      DOWNLOADING: product.lic"
    echo "#               TO: ${output}"
    cd /tmp || exit 2
    if test -n "${dryRun}"; then
        cat << END_CURL
        curl -GsSL \
            -w '%{http_code}' \
            -H "product: ${productShortName}" \
            -H "version: ${licenseVersion}" \
            -H "devops-user: ${devopsUser}" \
            -H "devops-key: ${devopsKey}" \
            -H "devops-app: ${devopsApp}" \
            -o "${output}" \
            "${licenseURL}"
END_CURL
    else
        if _curl -H "devops-purpose: license" -H "product: ${productShortName}" -H "version: ${licenseVersion}" -o "${output}" "${licenseURL}"; then
            echo_green "Successful download of ${productShortName} ${licenseVersion} license"
            exitCode=0
        else
            echo_red "Failed to obtain a license for ${productShortName} ${licenseVersion}"
        fi
    fi
else
    echo "#      DOWNLOADING: ${prodFile}"
    echo "#               TO: ${output}"
    cd /tmp || exit 2

    if test -n "${dryRun}"; then
        echo curl -sSL -w '%{http_code}' -o "${output}" -H "devops-user: ${devopsUser}" -H "devops-key: ${devopsKey}" -H "devops-app: ${devopsApp}" "${url}"
    else
        if test -n "${verifyGPGSignature}"; then
            keyFile=$(getGPGKeyFile)
            if test -n "${keyFile}" && test "${keyFile}" != "null"; then
                server="${defaultURL}${keyFile}"
                key="file"
            else
                server=$(getGPGKeyServer)
                key=$(getGPGKeyID)
            fi
            if download_and_verify "${url}" "${server}" "${key}" "${output}"; then
                echo_green "Successful download and verification of ${url}"
                exitCode=0
            else
                echo_red "Failed to obtain a verified copy of ${url}"
            fi
        else
            if _curl --header "devops-purpose: payload-unsigned" --output "${output}" "${url}"; then
                echo_green "Successful download of ${prodFile}"
                exitCode=0
            else
                echo_red "Unable to download ${prodFile}"
            fi
        fi
    fi
fi

echo "######################################################################"

# Need this exit of 0, since the last test of the curlResult will return a 1
cleanup
test ${exitCode} -ne 0 && saveOutcome
exit ${exitCode}
