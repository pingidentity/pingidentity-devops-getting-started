#!/usr/bin/env sh
set -x

usage ()
{
cat <<END_USAGE
Usage: ${SCRIPT} {options}
    where {options} include:

    *-p, --path {path/to/data.zip}
        path to the data.zip file must be named 'data.zip' (e.g. ~/pf/instance/data/data.zip)
    *-s, --source {s_hostname}
        The hostname to search for. (e.g. devops.pingidentity.com)
    -v, --variable (destination_variable)
        The variable name that will replace source 
        (e.g. 'PF_ENGINE_HOSTNAME' will turn to '\${PF_ENGINE_HOSTNAME}')
        if not provided, will default to \${SET_HOSTNAME} 
    -R, --rename
        will rename old data.zip. 
        HINT: if using for server-profile use this flag. 
    -h, --help
        Display general usage information

    Example:
      Deploy the fullstack usecase

      ${SCRIPT} -u fullstack

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

output_var="SET_HOSTNAME"
while ! test -z ${1} ; do
  case "${1}" in
    -s|--source)
    shift 
    if test -z "${1}" ; then
      exit_usage "Error: must pass source "
    fi
    s_hostname="${1}"
    ;;

    -v|--variable)
    shift 
    if test -z "${1}" ; then
      exit_usage "Error: must pass desired variable name "
    fi
    output_var="${1}"
    ;;

    -p|--path)
      shift
      if ! test -f "${1}" -o -d "${1}" ; then
      exit_usage "Error - file or directory does not exist: ${1}"
      fi
      in_data_config_path="${1}"
      in_data_config_dir=$( dirname "${in_data_config_path}" )
      in_data_config_name=$( basename "${in_data_config_path}" )
    ;;
    -R|--rename)
      rename_datazip=true
    ;;

    -h|--help)
      exit_usage
    ;;

    *)
      exit_usage "Unrecognized Option"
      ;;
  esac
  shift
done

if test -z ${in_data_config_path} ; then
  exit_usage "Must send path to data.zip"
fi

if test -z ${s_hostname} ; then
  exit_usage "Must send source hostname to look for"
fi

# case "${in_data_config_path}" in
#   *data.zip) in_data_config_name="data.zip";;
#   *data.zip.subst) in_data_config_name="data.zip.subst";;
#   *data) in_data_config_name="data" ;;
#   *data.json) in_data_config_name="data.json" ;;
#   *) exit_usage "path must end at 'data.zip','data.json' or '/data' " ;;
# esac

_pwd=${PWD}
data_tmp_dir="/tmp/data_archive"
mkdir -p ${data_tmp_dir}

if test "${in_data_config_name}" = "data.zip" -o "${in_data_config_name}" = "data.zip.subst" ; then
  unzip -qd "${data_tmp_dir}/data" "${in_data_config_path}"
  data_to_config="${data_tmp_dir}/data"
  # in_data_config_dir=$(echo "${in_data_config_path}" | sed 's/\/data\.zip$//')
elif test "${in_data_config_name}" = "data" ; then
  cp -r "${in_data_config_path}" "${data_tmp_dir}/."
  data_to_config="${data_tmp_dir}/data"
  # in_data_config_dir=$(echo "${in_data_config_path}" | sed 's/\/data$//')
elif test "${in_data_config_name}" = "data.json" ; then
  cp "${in_data_config_path}" "${data_tmp_dir}/."
  data_to_config="${data_tmp_dir}"/data.json
  # in_data_config_dir=$(echo "${in_data_config_path}" | sed 's/\/data\.json$//')
fi


if grep -qr "${s_hostname}" "${data_to_config}" ; then
  echo "found ${s_hostname} in these files: "
  grep -irl "${s_hostname}" "${data_to_config}"
else
  echo "couldn't find the provided hostname, are you sure it's there?"
  rm -rf "${data_tmp_dir}"
  exit 1
fi

answer=n
echo "replace all .json/.xml occurences with ${output_var}? y/n [n]"
read answer

output_var=$( echo "${output_var}" | sed 's/-/\\-/g' )
output_var=$( echo "${output_var}" | sed 's/_/\\_/g' )
output_var=$( echo "${output_var}" | sed 's/\./\\./g' )
# output_var=$( echo "${output_var}" | sed 's/\$/\\$/g' ) 
echo "output_var=${output_var}"
s_hostname=$( echo "${s_hostname}" | sed 's/-/\\-/g' )
s_hostname=$( echo "${s_hostname}" | sed 's/\./\\./g' )
echo "source_hostname=${s_hostname}"

if test "${answer}" = "y" ; then
  json=.json  
  xml=.xml
  echo "going to: ${data_tmp_dir}"
  cd ${data_tmp_dir} || exit
  grep -irl "${s_hostname}" "${data_to_config}" | while read -r fname ; do echo "mv to ${fname}.subst"
    case "${fname}" in 
      *.json) mv "${fname}" "${fname}".subst;;
      *.xml) mv "${fname}" "${fname}".subst;;
      *) echo "skipping: ${fname}" ;;
    esac
  done
  echo "begin replacing..."
  # ls /tmp/data_archive/data
  find "${data_to_config}" -name '*.subst' -print0 | xargs -0 sed -i '' "s/${s_hostname}/\\$\{${output_var}\}/g"
  
  if test "${rename_datazip}" = "true" ; then
    cp -r "${in_data_config_path}" "${in_data_config_path}".bak
  fi
  if test -d "${in_data_config_path}" ; then
      rm -r "${in_data_config_path}"
  fi
  mv "${data_to_config}" "${in_data_config_dir}"/
  
  cd "${_pwd}" || exit
else 
  # grep -irn "${s_hostname}" . | while read -r line ; do \
  #   echo "replace this? y/n: ${line}" ; \
  #   read answer ; \
  #   if test ${answer} = "y" ; then \
  #     echo "replaced" ; \
  #   fi ; \
  # done


  echo "chose not to replace"
fi

rm -rf "${data_tmp_dir}"