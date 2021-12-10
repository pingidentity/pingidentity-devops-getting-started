#!/usr/bin/env sh
usage ()
{
cat <<END_USAGE
Usage:  02-upgrade.sh [pingfederate-semver] {options}
    * required
    where {options} include:
    -u,--devops-user
        value of PING_IDENTITY_DEVOPS_USER
    -k,--devops-key
        value of PING_IDENTITY_DEVOPS_KEY
        
END_USAGE
exit 99
}
exit_usage()
{
    echo "$*"
    usage
    exit 1
}

echo "${1}" | grep -Eq '^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}$'
if test $? -eq 0 ; then
  NEW_PF_VERSION="${1}"
  shift
else
  exit_usage "Invalid Desired Pingfederate Version Provided: ${1}"
fi

while ! test -z ${1} ; do
  case "${1}" in
    --devops-user|-u)
      export PING_IDENTITY_DEVOPS_USER="${1}"
      shift;;
    --devops-key|-k)
      export PING_IDENTITY_DEVOPS_KEY="${1}"
      shift;;
    --verbose|-v)
      set -x
      shift;;
    -h|--help)
      exit_usage ;;
    *)
      exit_usage "Unrecognized Option ${1}" ;;
  esac
  shift
done

if test -z "${NEW_PF_VERSION}" || test -z "${PING_IDENTITY_DEVOPS_USER}" || test -z "${PING_IDENTITY_DEVOPS_KEY}" ; then
  exit_usage
fi

set -e
NEW_PF_VERSION="${NEW_PF_VERSION:-10.3.4}"

sh /opt/staging/hooks/get-bits.sh -p pingfederate -v "${NEW_PF_VERSION}" -u "${PING_IDENTITY_DEVOPS_USER}" -k "${PING_IDENTITY_DEVOPS_KEY}" -c
unzip -d /opt/new "/tmp/pingfederate-${NEW_PF_VERSION}.zip"
  ## download license to /tmp/pingfederate.lic
sh /opt/staging/hooks/get-bits.sh -p pingfederate -v "${NEW_PF_VERSION}" -u "${PING_IDENTITY_DEVOPS_USER}" -k "${PING_IDENTITY_DEVOPS_KEY}" -l -c

_pfPort=$(netstat -tuln | grep 0.0.0.0:[0-9] | awk  '{print $4}' | cut -b9-)
if test $(curl -kSs "https://127.0.0.1:${_pfPort}" --write-out '%{http_code}' 2>&1) -eq 302 -o 200 \
  || test $(curl -kSs "http://127.0.0.1:${_pfPort}" --write-out '%{http_code}' 2>&1) -eq 302 -o 200; then 
  echo "PF is running, stopping now"
  pkill /opt/java/bin/java
  ## let pf shutdown
  sleep 15
else
  echo "PF isn't running, continuing"
fi

# Create Dirs for tracking
mkdir -p /opt/current /opt/current_bak /opt/staging_bak
cp -r /opt/out/instance /opt/current_bak
cp -r /opt/current_bak/instance  /opt/current/pingfederate
cp -Ru /opt/staging/. /opt/staging_bak

cd /opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/upgrade/bin
sh upgrade.sh /opt/current -l /tmp/pingfederate.lic --release-notes-reviewed

## diff returns 1 if differences are found. use `|| true` to allow script to continue
## diff -r /opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/server/default/data /opt/current_bak/instance/server/default/data || true

## Profile Diff:
echo "START PROFILE DIFF"
stgFiles=$(find /opt/staging_bak/instance/ -type f)
for f in $stgFiles ; do 
  echo "$f" |  cut -d"/" -f5- >> /tmp/stagingFileList
done

set +e
set -x
while read -r line; do
  newPfDir=$(dirname "/opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/${line}")
  newProfileDir=$(dirname "/opt/new_staging/instance/${line}")
  mkdir -p "${newPfDir}" "${newProfileDir}"
  cp "/opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/${line}" "/opt/new_staging/instance/${line}"
  diff -q "/opt/staging_bak/instance/${line}" "/opt/new_staging/instance/${line}" >> /tmp/stagingDiffs
done < /tmp/stagingFileList
set +x

rm -rf /opt/out/instance/server/default/data > /dev/null 2>&1 
if test $? -eq 0 ; then
  rm -rf /opt/out/*
else
  rm -rf /opt/out/instance/server/default/data/*
fi

cp -Ru /opt/new/pingfederate-${NEW_PF_VERSION}/pingfederate/. /opt/out/instance