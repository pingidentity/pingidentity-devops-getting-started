#!/usr/bin/env sh
set -x
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
data_tmp_dir="/tmp/data_archive"
dest_var="SET_HOSTNAME"
#TODO add interactive mode
    # -I, --interactive
    #     be asked before confirming replacement.
    #     ignored if using -e, --env_file
usage ()
{
cat <<END_USAGE
Usage:  {options} 
    NOTE: case-insensitivity is not supported
    where {options} include:

    *-p, --path {path/to/data.zip}
        path to the data.zip file must be named 'data.zip' (e.g. ~/pf/instance/data/data.zip)
    -s, --source {source_host}
        The hostname to search for. (e.g. devops.pingidentity.com)
    -v, --variable (destination_variable)
        The variable name that will replace source 
        (e.g. 'PF_ENGINE_HOSTNAME' will turn to '\${PF_ENGINE_HOSTNAME}')
        if not provided, will default to \${SET_HOSTNAME} 
    -e, --env-file
        path to environment file to use INSTEAD of source an variable 
    -B, --backup
        create config.bak for backup
        HINT: might as well always do this...
    -o, --output
        define output name. if 
    -h, --help
        Use for instructions on usage

    * Required option
END_USAGE
exit 99
}
exit_usage()
{
    echo "$*"
    echo
    usage
    exit 1
}
while ! test -z ${1} ; do
  case "${1}" in
    -s|--source)
      shift 
      if test -z "${1}" ; then
        exit_usage "Error: must pass hostname to look for "
      fi
      source_host="${1}" ;;
    -v|--variable|-d|--destination)
      shift 
      if test -z "${1}" ; then
        exit_usage "Error: must pass desired variable name "
      fi
      dest_var="${1}" ;;
    -e|--env-file)
      shift 
      if test -z "${1}" ; then
        exit_usage "Error: must pass path to env_vars file "
      elif test -f ${1} ; then
        env_file=${1}
      fi
      ;;
    -p|--path)
      shift
      in_data_config_fpath=$( get_abs_filename "${1}" )
      echo ${in_data_config_fpath}
      in_data_config_dir=$( dirname "${in_data_config_fpath}" )
      in_data_config_name=$( basename "${in_data_config_fpath}" ) ;;
    -o|--output)
      shift
      output_name="${1}";;
    -B|--backup)
      backup_config="true" ;;
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
  
  federate.dev.pingidentity.com PF_HOSTNAME
  federate.prod.pingidentity.com PF_HOSTNAME
  access.dev.pingidentity.com PA_HOSTNAME
  hostname variable_to_replace_it_with

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

prep_variablize(){
  if test "${backup_config}" = "true" ; then
    cp -r "${in_data_config_fpath}" "${in_data_config_fpath}.bak"
  fi

  mkdir -p ${data_tmp_dir}

  if test -f "${in_data_config_fpath}" ; then
    case "${in_data_config_name}" in 
        *.zip) 
          unzip -qd "${data_tmp_dir}/data" "${in_data_config_fpath}"
          data_to_config="${data_tmp_dir}/data" ;;
        *.zip.subst) 
          cp "${in_data_config_fpath}" "data.zip"
          unzip -qd "${data_tmp_dir}/data" "data.zip"
          data_to_config="${data_tmp_dir}/data" ;;
        *.subst)
          cp "${in_data_config_fpath}" "${data_tmp_dir}/${in_data_config_name}"
          data_to_config="${data_tmp_dir}/${in_data_config_name}"
          data_to_return="${data_tmp_dir}/${in_data_config_name}"
        ;;
        *)
          cp "${in_data_config_fpath}" "${data_tmp_dir}/${in_data_config_name}"
          data_to_config="${data_tmp_dir}/${in_data_config_name}"
          data_to_return="${data_tmp_dir}/${in_data_config_name}.subst"
        ;;
      esac
  elif test -d "${in_data_config_fpath}" ; then
    cp -r "${in_data_config_fpath}" "${data_tmp_dir}/data"
    data_to_config="${data_tmp_dir}/data"
  else
    exit_usage "invalid file to variablize or not found."
  fi
}

check_variablize() {
  if test -z "${source_host}" -a -z "${env_file}"; then
    exit_usage "Error: Must send source hostname to look for or proper env_vars file"
  fi
  if grep -iqr "${source_host}" "${data_to_config}" ; then
    echo "found ${source_host} in these files: "
    grep -irl "${source_host}" "${data_to_config}"
    answer=n
    if test "${is_interactive}" = "true" ; then
      echo "replace all .json/.xml occurences of ${source_host} with ${dest_var}? y/n [n]"
      read answer
    else
      answer=y
    fi
    return 0
  else
    echo "hostname not found: ${source_host}, skipping replace"
    return 1
  fi
}

variablize() {
  
    # prep variables
    dest_var=$( echo "${dest_var}" | sed 's/-/\\-/g' )
    dest_var=$( echo "${dest_var}" | sed 's/_/\\_/g' )
    dest_var=$( echo "${dest_var}" | sed 's/\./\\./g' )
    # dest_var=$( echo "${dest_var}" | sed 's/\$/\\$/g' ) 
    echo "dest_var=${dest_var}"
    source_host=$( echo "${source_host}" | sed 's/-/\\-/g' )
    source_host=$( echo "${source_host}" | sed 's/_/\\_/g' )
    source_host=$( echo "${source_host}" | sed 's/\./\\./g' )
    source_host=$( echo "${source_host}" | sed 's/\:/\\:/g' )
    echo "source_hostname=${source_host}"
    json=.json  
    xml=.xml
    
    # Begin find/replace
    echo "going to: ${data_tmp_dir}"
    cd ${data_tmp_dir}
    echo "appending.subst"
    grep -irl "${source_host}" "${data_to_config}" | while read -r fname ; do
      case "${fname}" in 
        *.json) mv "${fname}" "${fname}.subst";;
        *.xml) mv "${fname}" "${fname}.subst";;
        *) echo "skipping: ${fname}" ;;
      esac
    done
    echo "begin replacing..."
    # ls /tmp/data_archive/data
    find "${data_tmp_dir}" -name '*.subst' -print0 | xargs -0 sed -i '' "s/${source_host}/\\$\{${dest_var}\}/g"
    variablized="true"
}

return_data() {
  # to zip or not to zip
  if test ! -z "${output_name}" ; then
    case "${output_name}" in
      *.zip | *.zip.subst)
        case "${in_data_config_name}" in 
          *.zip | *.zip.subst)
            cd "${data_tmp_dir}"
            zip -qr "${output_name}" "data"
            data_to_return="${data_tmp_dir}/${output_name}"
          ;;
        esac
      ;;
      *)
        if test ! "${data_to_return}" = "${data_tmp_dir}/${output_name}"  && test ! -z "${data_to_return}"; then
          mv "${data_to_return}" "${data_tmp_dir}/${output_name}"
        fi
        data_to_return="${data_tmp_dir}/${output_name}"
      ;;
    esac
  else 
    case "${in_data_config_name}" in 
      *.zip | *.zip.subst)
        cd "${data_tmp_dir}"
        zip -qr "data.zip.subst" "data"
        data_to_return="${data_tmp_dir}/data.zip.subst"
        ;;
    esac
  fi
  
  if test "${variablized}" = "true" ; then
    if test "$( basename ${data_to_return} )" = "$( basename ${in_data_config_fpath} )"  ; then
      rm -r "${in_data_config_fpath}"
    fi
    cp -fr "${data_to_return}" "${in_data_config_dir}"
  fi
    cd "${_pwd}"
    rm -rf "${data_tmp_dir}"
}

if ! test -z ${env_file} ; then 
  # backup_config="true"
  is_interactive="false"
  prep_variablize
  set_vars() {
    source_host="${1}"
    dest_var="${2}"
  }
  while read line || [ -n "$line" ] ; do 
    set_vars ${line}
    check_variablize
    test $? -eq 0 && variablize
  done < "${env_file}"
  return_data
else 
  prep_variablize
  set_vars() {
    source_host="${1}"
    dest_var="${2}"
  }
  check_variablize
  test $? -eq 0 && variablize
  return_data
fi