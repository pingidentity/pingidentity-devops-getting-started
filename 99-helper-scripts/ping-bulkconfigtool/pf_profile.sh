#!/usr/bin/env sh
# set -x
# _initialDir="${PWD}"
# _scriptDir="${PWD}/ci_tools/pf_build_profile"
# cd "${_scriptDir}" || exit

usage ()
{
cat <<END_USAGE
Usage:  {options}
    where {options} include:

    *-r, --release {helm-release-name}

    -p, --password
        path to environment file to use INSTEAD of source an variable
    -s, --source
        instead of env-file, search for single string. (e.g. devops.pingidentity.com)
    -d, --destination
        if passing --source, variable name that will replace source
        (e.g. 'PF_ENGINE_HOSTNAME' will turn to '\${PF_ENGINE_HOSTNAME}')
    -B, --backup
        create config.bak for backup
        HINT: might as well always do this...
    -o, --output
        define output name.
    -h, --help
        Use for instructions on usage

    * Required option
END_USAGE
exit 99
}
exit_usage()
{
    echo "$*"
    usage
    exit 1
}


while ! test -z ${1} ; do
  case "${1}" in
    -s|--source)
      shift
      if test -z "${1}" ; then
        exit_usage "Error: source paramater not passed "
      fi
      sourceHost="${1}" ;;
    -v|--variable|-d|--destination)
      shift
      if test -z "${1}" ; then
        exit_usage "Error: destination paramater not passed "
      fi
      destVar="${1}" ;;
    -e|--env-file)
      shift
      if test -z "${1}" ; then
        exit_usage "Error: env-file paramater not passed "
      elif test ! -f ${1} ; then
        exit_usage "Error: env-file not found"
      else envFile=${1}
      fi
      ;;
    -p|--path)
      shift
      inConfigFpath=$( get_abs_filename "${1}" )
      # echo ${inConfigFpath}
      inConfigDir=$( dirname "${inConfigFpath}" )
      inConfigBase=$( basename "${inConfigFpath}" ) ;;
    -o|--output)
      shift
      outputName="${1}";;
    -B|--backup)
      backupConfig="true" ;;
    # -I|--interactive)
    #   is_interactive="true" ;;
    -h|--help)
      exit_usage "The goal of this script find and replace
  hostnames with variables on a PF or PA config archive
  This is helpful when using the config in a docker server-profile.
  More info on server-profiles:
  https://devops.pingidentity.com/reference/profileStructures/
  This can accept config exports from either PingFederate or PingAccess.

  The BEST way to use this script is to:
  1. place all hosts and output_variables in a txt file. Like so:

  PF_HOSTNAME=federate.dev.pingidentity.com
  PF_HOSTNAME=federate.prod.pingidentity.com
  PA_HOSTNAME=access.dev.pingidentity.com
  variable=string

  2. run command like so:
  ./variablize_pf_pa_config.sh -p path/to/data.zip -e /path/to/env_hosts -B

  Alternatively, you can look for a single hostname:
  ./variablize_pf_pa_config.sh -p path/to/data.zip -s fed.dev.pingidentity.com \\
    -d PF_HOSTNAME -B

  NOTE: the standard output with return the same file type with added suffix: .subst
  You can override this to change the file name to something more friendly to server-profiles
  examples:
    ./variablize_pf_pa_config.sh -p path/to/pingfederate-data-09-16-2019.zip \\
      -e /path/to/env_hosts -B -o data
    this will output a substed data directory.

    ./variablize_pf_pa_config.sh -p path/to/pa-data-09-16-2019.16.28.30.json \\
       -e /path/to/env_hosts -B -o data.json.subst
    this will output data.json.subst

                   ";;
    *)
      exit_usage "Unrecognized Option" ;;
  esac
  shift
done


test "${1}" == "-B" && _backup=true

getPfVars

pVersion="$(git rev-parse --short HEAD)"

echo "Creating output folder..."
mkdir -p "${pVersion}"
export pVersion

echo "Downloading config from ${PF_ADMIN_PUBLIC_HOSTNAME}..."
curl -X GET --basic -u Administrator:${PING_IDENTITY_PASSWORD} --header 'Content-Type: application/json' --header 'X-XSRF-Header: PingFederate' "https://${PF_ADMIN_PUBLIC_HOSTNAME}/pf-admin-api/v1/bulk/export" --insecure | jq -r > "${pVersion}/data.json"

echo "Creating/modifying ${pVersion}/env_vars and ${pVersion}/data.json.subst..."
java -jar bulk-config-tool.jar pf-config.json "${pVersion}/data.json" "${pVersion}/env_vars" "${pVersion}/data.json.subst" > "${pVersion}/export-convert.log"

getGlobalVars | awk '{ print length($0) " " $0; }' | sort -r -n | cut -d ' ' -f 2- > tmpHosts
./variablize.sh -p "${pVersion}/data.json.subst" -e tmpHosts -B
echo "#### GLOBAL ENV VARS #####" >> "${pVersion}/env_vars"
cat tmpHosts >> "${pVersion}/env_vars"
rm tmpHosts
if test -f hosts ; then
  ./variablize.sh -p "${pVersion}/data.json.subst" -e hosts
  echo "#### HOSTS FILE VARS #####" >> "${pVersion}/env_vars"
  cat hosts >> "${pVersion}/env_vars"
fi

mv "${pVersion}/env_vars" "${pVersion}/tmp_env_vars"
sed 's/=.*$/=/' "${pVersion}/tmp_env_vars" > "${pVersion}/env_vars"
cp -f "${pVersion}/env_vars" "vars_diff"

cd "${_initialDir}" || exit
cp "${_scriptDir}/${pVersion}/data.json.subst" "profiles/pingfederate_admin/instance/bulk-config/data.json.subst"
test ! $_backup && rm -rf "${_scriptDir}/${pVersion}/"