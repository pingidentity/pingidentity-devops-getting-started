#!/usr/bin/env sh

test "${VERBOSE}" = "true" && set -x

# User usage function
usage() {
    test -n "${*}" && echo "${*}"
    cat << END_USAGE
Usage: ${0} [Pingfederate Version] {options}
    where {options} include:
    -u,--devops-user
        value of PING_IDENTITY_DEVOPS_USER
    -k,--devops-key
        value of PING_IDENTITY_DEVOPS_KEY
END_USAGE
    exit 99
}

# Ensure a PingFederate version has been provided
test -z "${1}" && usage "ERROR: A PingFederate version must be provided to the script" && exit 1

# Validate and read in PingFederate version to upgrade to
echo "${1}" | grep -Eq '^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}$'
if test "${?}" -eq 0; then
    NEW_PF_VERSION="${1}"
    shift
else
    usage "ERROR: Invalid Pingfederate Version Provided: ${1}"
fi

# Read in passed options
while ! test -z "${1}"; do
    case "${1}" in
        -u | --devops-user)
            test -z "${2}" && usage "You must specify a Devops User with the ${1} option"
            shift
            export PING_IDENTITY_DEVOPS_USER="${1}"
            ;;
        -k | --devops-key)
            test -z "${2}" && usage "You must specify a Devops Key with the ${1} option"
            shift
            export PING_IDENTITY_DEVOPS_KEY="${1}"
            ;;
        -h | --help)
            usage
            ;;
        *)
            usage "ERROR: Unrecognized Option ${1}"
            ;;
    esac
    shift
done

# Make sure all required variables are now present in the environment
if test -z "${NEW_PF_VERSION}" || test -z "${PING_IDENTITY_DEVOPS_USER}" || test -z "${PING_IDENTITY_DEVOPS_KEY}"; then
    usage "ERROR: One or more variables are not specified: PingFederate Version, Devops User, and Devops Key"
fi

# Make sure "pingfederate-${NEW_PF_VERSION}.zip" has been provided at "/tmp/pingfederate-${NEW_PF_VERSION}.zip"
echo "INFO: Checking for new PingFederate zip"
new_pf_zip_path="/tmp/pingfederate-${NEW_PF_VERSION}.zip"
if ! test -f "${new_pf_zip_path}"; then
    echo "ERROR: No Pingfederate zip file found at file location ${new_pf_zip_path}"
    exit 1
fi

# Extract new pingfederate bits
echo "INFO: Extracting new PingFederate from zip"
unzip -qd /opt/new "${new_pf_zip_path}"
test "${?}" -ne 0 && echo "ERROR: Failed to unzip file ${new_pf_zip_path}" && exit 1

# Make sure "pingfederate.lic" has been provided at "/tmp/pingfederate.lic
echo "INFO: Checking for PingFederate license"
new_pf_lic_path="/tmp/pingfederate.lic"
if ! test -f "${new_pf_lic_path}"; then
    echo "ERROR: No Pingfederate license file found at file location ${new_pf_lic_path}"
    exit 1
fi

# Get the running pingfederate port
echo "INFO: Attempting to retrieve the running PingFederate's port. If Pingfederate is not running, this will fail"
pf_port=$(netstat -tuln | grep "0.0.0.0:[0-9]" | awk '{print $4}' | cut -b9-)

pf_https_response="$(curl -kSs "https://127.0.0.1:${pf_port}" --write-out '%{http_code}' 2>&1)"
pf_http_response="$(curl -kSs "http://127.0.0.1:${pf_port}" --write-out '%{http_code}' 2>&1)"

if test "${pf_https_response}" -eq 302 ||
    test "${pf_https_response}" -eq 200 ||
    test "${pf_http_response}" -eq 302 ||
    test "${pf_http_response}" -eq 200; then
    echo "INFO: PingFederate is running, stopping now"
    pkill /opt/java/bin/java
    test "${?}" -ne 0 && echo "ERROR: Failed to stop Pingfederate" && exit 1

    # Let PingFederate shutdown
    sleep 15
else
    echo "INFO: PingFederate is not running, continuing"
fi

# Create directories for tracking
echo "INFO: Creating the following directories: /opt/current, /opt/current_bak, /opt/staging_bak"
mkdir -p /opt/current /opt/current_bak /opt/staging_bak
test "${?}" -ne 0 && echo "ERROR: Failed to create one or more of the following directories: /opt/current, /opt/current_bak, /opt/staging_bak" && exit 1

# Backup instance
echo "INFO: Backing up /opt/out/instance"
cp -r /opt/out/instance /opt/current_bak
test "${?}" -ne 0 && echo "ERROR: Failed to copy backup of /opt/out/instance into /opt/current_bak" && exit 1

# Place the backup into current directory to run the upgrade utility from
echo "INFO: Copying instance to /opt/current to run upgrade utility"
cp -r /opt/current_bak/instance /opt/current/pingfederate
test "${?}" -ne 0 && echo "ERROR: Failed to copy backup of /opt/current_bak/instance into /opt/current/pingfederate" && exit 1

# Backup staging
echo "INFO: Backing up /opt/staging"
cp -Ru /opt/staging/. /opt/staging_bak
test "${?}" -ne 0 && echo "ERROR: Failed to copy backup of /opt/staging/. into /opt/staging_bak" && exit 1

# Attempt to change directory to upgrade utility folder.
echo "INFO: Changing to upgrade utility directory: /opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/upgrade/bin"
cd "/opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/upgrade/bin" || exit 1

# Run the upgrade utility
echo "INFO: Running the upgrade utility"
sh upgrade.sh /opt/current -l "${new_pf_lic_path}" --release-notes-reviewed
test "${?}" -ne 0 && echo "ERROR: The upgrade utility failed" && exit 1

## Profile Diff:
echo "INFO: Start profile diff"
stgFiles=$(find /opt/staging_bak/instance/ -type f)
for f in $stgFiles; do
    echo "$f" | cut -d"/" -f5- >> /tmp/stagingFileList
done

set -x
while read -r line; do
    new_pf_dir=$(dirname "/opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/${line}")
    new_profile_dir=$(dirname "/opt/new_staging/instance/${line}")
    mkdir -p "${new_pf_dir}" "${new_profile_dir}"
    cp "/opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/${line}" "/opt/new_staging/instance/${line}" > /dev/null 2>&1
    diff --brief "/opt/staging_bak/instance/${line}" "/opt/new_staging/instance/${line}" >> /tmp/stagingDiffs 2>&1
done < /tmp/stagingFileList
set +x

# Remove old instance, which is backed up in /opt/current_bak
echo "INFO: Updating /opt/out/instance with upgraded pingfederate instance"
rm -rf /opt/out/instance/server/default/data > /dev/null 2>&1
if test $? -eq 0; then
    rm -rf /opt/out/*
else
    rm -rf /opt/out/instance/server/default/data/*
fi

# Overlay upgraded instance into /opt/out
cp -Ru "/opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/." "/opt/out/instance"
test "${?}" -ne 0 && echo "ERROR: Failed to copy upgraded instance from /opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/. into /opt/out/instance" && exit 1

exit 0
