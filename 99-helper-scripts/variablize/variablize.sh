#!/usr/bin/env sh
# set -x
## init vars
get_abs_filename() {
  # $1 : relative filename
  filename=$1
  parentdir=$(dirname "${filename}")

  if [ -d "${filename}" ]; then
      echo "$(cd "${filename}" && pwd)"
  elif [ -d "${parentdir}" ]; then
    echo "$(cd "${parentdir}" && pwd)/$(basename "${filename}")"
  fi
}
_pwd=${PWD}
tmpDir="tmp"
# destVar="SET_HOSTNAME"
#TODO add interactive mode
    # -I, --interactive
    #     be asked before confirming replacement.
    #     ignored if using -e, --envFile
usage ()
{
cat <<END_USAGE
Usage:  {options} 
    NOTE: case-insensitivity is not supported
    where {options} include:

    *-p, --path {path/to/data_to_variablize}
        path to the file or directory to variablize (e.g. ~/pf/instance/data/data.zip)
    -e, --env-file
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
  https://pingidentity-devops.gitbook.io/devops/server-profiles
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

if test -n "${sourceHost}" -o -n "${destVar}" ; then 
  test -n "${envFile}" && exit_usage "can't send source/dest AND env file"
fi
if test -z "${sourceHost}" -o -z "${destVar}" ; then 
  test -z "${envFile}" && exit_usage "must send source/dest OR env file"
fi

# sets up the data to config
prep_variablize(){
  if test "${backupConfig}" = "true" ; then
    cp -r "${inConfigFpath}" "${inConfigFpath}.bak"
  fi
  mkdir -p ${tmpDir}

  if test -f "${inConfigFpath}" ; then
    case "${inConfigBase}" in 
        *.zip | *.zip.subst) 
          cp "${inConfigFpath}" "${tmpDir}/data.zip"
          unzip -qd "${tmpDir}/data" "${tmpDir}/data.zip"
          configData="${tmpDir}/data" ;;
        # TODO: see if this is needed. 
        # *.subst)
        #   cp "${inConfigFpath}" "${tmpDir}/${inConfigBase}"
        # ;;
        *)
          cp "${inConfigFpath}" "${tmpDir}/${inConfigBase}"
          configData="${tmpDir}/${inConfigBase}"
          # TODO: see if this is needed. 
          # returnData="${tmpDir}/${inConfigBase}.subst"
        ;;
      esac
  elif test -d "${inConfigFpath}" ; then
    cp -r "${inConfigFpath}" "${tmpDir}/${inConfigBase}"
    configData="${tmpDir}/${inConfigBase}"
  else
    exit_usage "invalid file to variablize or not found."
  fi

  # todo: may need to add returnData

}

check_variablize() {
  if test -z "${sourceHost}" -a -z "${envFile}"; then
    exit_usage "Error: Must send source hostname to look for or proper env_vars file"
  fi
  if grep -iqr "${sourceHost}" "${configData}" ; then
    echo "found ${sourceHost} in these files: "
    grep -irl "${sourceHost}" "${configData}"
    answer=n
    if test "${is_interactive}" = "true" ; then
      echo "replace all .json/.xml occurences of ${sourceHost} with ${destVar}? y/n [n]"
      read answer
    else
      answer=y
    fi
    return 0
  else
    echo "INFO: source: ${sourceHost} not found, skipping replace"
    return 1
  fi
}

variablize() {
  
    # prep variables
    destVar=$( echo "${destVar}" | sed 's/-/\\-/g' )
    destVar=$( echo "${destVar}" | sed 's/_/\\_/g' )
    destVar=$( echo "${destVar}" | sed 's/\./\\./g' )
    # destVar=$( echo "${destVar}" | sed 's/\$/\\$/g' ) 
    # echo "destVar=${destVar}"
    sourceHost=$( echo "${sourceHost}" | sed 's/-/\\-/g' )
    sourceHost=$( echo "${sourceHost}" | sed 's/_/\\_/g' )
    sourceHost=$( echo "${sourceHost}" | sed 's/\./\\./g' )
    sourceHost=$( echo "${sourceHost}" | sed 's/\:/\\:/g' )
    # echo "sourceHostname=${sourceHost}"
    
    # Begin find/replace
    echo "INFO: variablizing"
    grep -irl "${sourceHost}" "${configData}" | while read -r fname ; do
      case "${fname}" in 
        *.json | *.xml | *.dsconfig | *.ldif) mv "${fname}" "${fname}.subst";;
        # *.xml) mv "${fname}" "${fname}.subst";;
        *.subst) echo "${fname}" ;;
        *) echo "skipping: ${fname}" ;;
      esac
    done
    test -f "${configData}.subst" && configData="${configData}.subst"
    # ls /tmp/data_archive/data
    find "${configData}" -name '*.subst' -print0 | xargs -0 sed -i '' "s/${sourceHost}/\\$\{${destVar}\}/g"
    variablized="true"
}

return_data() {
  # to zip or not to zip
  if test -n "${outputName}" ; then
    case "${outputName}" in
      *.zip | *.zip.subst)
        # case "${inConfigBase}" in 
        #   *.zip | *.zip.subst)
        #     # cd "${tmpDir}"
          zip -qr "${outputName}" "${configData}"
          returnData="${tmpDir}/${outputName}"
          # ;;
        # esac
      ;;
      *)
        test "${configData}" != "${tmpDir}/${outputName}" && mv "${configData}" "${tmpDir}/${outputName}"
        returnData="${tmpDir}/${outputName}"
      ;;
    esac
  else 
    case "${inConfigBase}" in 
      *.zip | *.zip.subst)
        cd "${tmpDir}" || exit_usage "can't cd"
        zip -qr "data.zip.subst" "$(basename "${configData}")"
        returnData="${tmpDir}/data.zip.subst"
        cd "${_pwd}" || exit_usage "can't cd"
        ;;
      *)
        returnData="${configData}"
    esac
  fi
  
  if test "${variablized}" = "true" ; then
    
    rm -rf "${inConfigFpath}"
    cp -fr "${returnData}" "${inConfigDir}/."
  fi
    rm -rf "${tmpDir}"
}

if ! test -z "${envFile}" ; then
  is_interactive="false"
  prep_variablize
  IFS='='
  grep -v '^#' "${envFile}" >> "${tmpDir}/env"
  cat "${tmpDir}/env"
  while read -r destVar sourceHost ; do
    echo "${destVar}  ${sourceHost}"
    check_variablize
    test $? -eq 0 && variablize
  done < "${tmpDir}/env"
  rm "${tmpDir}/env"
  unset IFS
  return_data
else
  prep_variablize
  set_vars() {
    sourceHost="${1}"
    destVar="${2}"
  }
  check_variablize
  test $? -eq 0 && variablize
  return_data
fi