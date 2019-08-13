#!/usr/bin/env sh
# set -x

usage ()
{
cat <<END_USAGE
Usage:  {options} 
    NOTE: case-insensitivity is not supported
    where {options} include:

    *-p, --path {path/to/data.zip}
        path to the data.zip file must be named 'data.zip' (e.g. ~/pf/instance/data/data.zip)
    *-s, --source {source_host}
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
    -I, --interactive
        be asked before confirming replacement.
        ignored if using -e, --env_file
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
_pwd=${PWD}
data_tmp_dir="/tmp/data_archive"
dest_var="SET_HOSTNAME"
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
      fi
      env_file=${1};;
    -p|--path)
      shift
      in_data_config_fpath="${1}"
      in_data_config_dir=$( dirname "${in_data_config_fpath}" )
      in_data_config_name=$( basename "${in_data_config_fpath}" ) ;;
    -B|--backup)
      rename_datazip="true" ;;
    -I|--interactive)
      is_interactive="true" ;;
    -h|--help)
      exit_usage "The goal of this script is to take a PF or PA
  configuration archive and replace hostnames with variables.
  This is useful when putting the config into a docker server-profile.
  More info on server-profiles:
  https://pingidentity-devops.gitbook.io/devops/server-profiles
  This can accept config exports from either PingFederate or PingAccess. 
  However the file or directory MUST be named:
  For PA: 'data.json' or 'data.json.subst'
  For PF: 'data.zip', 'data.zip.subst', '_data.zip_' (directory), 'data' (directory)
  
  The BEST way to use this script is to:
  1. place all hosts and output_variables in a txt file. Like so:
  
  federate.dev.pingidentity.com PF_HOSTNAME
  federate.prod.pingidentity.com PF_HOSTNAME
  access.dev.pingidentity.com PA_HOSTNAME
  hostname variable_to_replace_it_with

  2. run command like so:
  ./variablize_pf_pa_config.sh -p path/to/data.zip -e /path/to/env_hosts -R
                   ";;
    *)
      exit_usage "Unrecognized Option" ;;
  esac
  shift
done

if test -z "${source_host}" -a -z "${env_file}"; then
  exit_usage "Error: Must send source hostname to look for or proper env_vars file"
fi

prep_variablize(){
  
  mkdir -p ${data_tmp_dir}

  # Prep data_to_config
  if test "${in_data_config_name}" = "data.zip" -o "${in_data_config_name}" = "data.zip.subst" ; then
    if test -f "${in_data_config_fpath}" ; then
      unzip -qd "${data_tmp_dir}/data" "${in_data_config_fpath}"
      data_to_config="${data_tmp_dir}/data"
    elif test -f "${in_data_config_name}.subst" ; then
      if test "${is_interactive}" = "true" ; then
        use_subst="y"
        echo "Config file not found, use ${in_data_config_name}.subst instead? y/n [y]"
        read use_subst
        if test "${use_subst}" = "y" ; then
          echo "using subst instead"
          cp "${in_data_config_fpath}.subst" "${data_tmp_dir}/."
          data_to_config="${data_tmp_dir}/${in_data_config_name}.subst"
        else
          exit_usage "please enter a valid config path"
        fi
      else
        echo "using subst instead"
        unzip -qd "${data_tmp_dir}/data" "${in_data_config_fpath}.subst"
        data_to_config="${data_tmp_dir}/data"
      fi
    elif test ! -f "${in_data_config_name}" ; then
      if test -d "${in_data_config_dir}/_data.zip_" ; then
        if test "${is_interactive}" = "true" ; then
          use_subst="y"
          echo "Config file not found, use ${in_data_config_dir}/_data.zip_ instead? y/n [y]"
          read use_subst
          if test "${use_subst}" = "y" ; then
            echo "using _data.zip_ instead"
            cp -r "${in_data_config_dir}/_data.zip_" "${data_tmp_dir}/data"
            data_to_config="${data_tmp_dir}/data"
          else
            exit_usage "please enter a valid config path"
          fi
        else
          echo "using _data.zip_ instead"
          cp -r "${in_data_config_dir}/_data.zip_" "${data_tmp_dir}/data"
            data_to_config="${data_tmp_dir}/data"
        fi
      else
        exit_usage "Error - invalid config, or does not exist: ${in_data_config_fpath}"
      fi
    else
      exit_usage "Error - config file not found: ${in_data_config_fpath} "
    fi
    # in_data_config_dir=$(echo "${in_data_config_fpath}" | sed 's/\/data\.zip$//')
  elif test "${in_data_config_name}" = "data" -o "${in_data_config_name}" = "_data.zip_" ; then
    if test -d "${in_data_config_fpath}" ; then
      cp -r "${in_data_config_fpath}" "${data_tmp_dir}/data"
      data_to_config="${data_tmp_dir}/data"
    elif test -d "${in_data_config_dir}/_data.zip_" ; then
        if test "${is_interactive}" = "true" ; then
          use_subst="y"
          echo "Config not found, use ${in_data_config_dir}/_data.zip_ instead? y/n [y]"
          read use_subst
          if test "${use_subst}" = "y" ; then
            echo "using _data.zip_ instead"
            cp -r "${in_data_config_dir}/_data.zip_" "${data_tmp_dir}/data"
            data_to_config="${data_tmp_dir}/data"
          else
            exit_usage "please enter a valid config path"
          fi
        else
          echo "using _data.zip_ instead"
          cp -r "${in_data_config_dir}/_data.zip_" "${data_tmp_dir}/data"
          data_to_config="${data_tmp_dir}/data"
        fi
    else
      exit_usage "Error - invalid config, or does not exist: ${in_data_config_fpath}"
    fi
    # in_data_config_dir=$(echo "${in_data_config_fpath}" | sed 's/\/data$//')
  elif test "${in_data_config_name}" = "data.json" -o "${in_data_config_name}" = "data.json.subst" ; then
    if test ! -f "${in_data_config_fpath}" ; then 
      if test -f "${in_data_config_fpath}.subst" ; then
        if test "${is_interactive}" = "true" ; then
          use_subst="y"
          echo "Config file not found, use ${in_data_config_name}.subst instead? y/n [y]"
          read use_subst
          if test "${use_subst}" = "y" ; then
            echo "using subst instead"
            cp "${in_data_config_fpath}.subst" "${data_tmp_dir}/."
            data_to_config="${data_tmp_dir}/${in_data_config_name}.subst"
          fi
        else
          echo "using subst instead"
          cp "${in_data_config_fpath}.subst" "${data_tmp_dir}/."
          data_to_config="${data_tmp_dir}/${in_data_config_name}.subst"
        fi
      else 
        exit_usage "Error - invalid config, or does not exist: ${in_data_config_fpath}"
      fi
    else
      cp "${in_data_config_fpath}" "${data_tmp_dir}/."
      data_to_config="${data_tmp_dir}/${in_data_config_name}"
    fi
  else 
      exit_usage "Error - invalid config, or does not exist: ${in_data_config_fpath}"
  fi
    # anything to change?
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
    variablize
  else
    echo "couldn't find the provided hostname, are you sure it's there?"
    rm -rf "${data_tmp_dir}"
  fi
}

variablize() {
  # do work
  if test "${answer}" = "y" ; then

    dest_var=$( echo "${dest_var}" | sed 's/-/\\-/g' )
    dest_var=$( echo "${dest_var}" | sed 's/_/\\_/g' )
    dest_var=$( echo "${dest_var}" | sed 's/\./\\./g' )
    # dest_var=$( echo "${dest_var}" | sed 's/\$/\\$/g' ) 
    echo "dest_var=${dest_var}"
    source_host=$( echo "${source_host}" | sed 's/-/\\-/g' )
    source_host=$( echo "${source_host}" | sed 's/\./\\./g' )
    echo "source_hostname=${source_host}"
    json=.json  
    xml=.xml
    echo "going to: ${data_tmp_dir}"
    cd ${data_tmp_dir}
    grep -irl "${source_host}" "${data_to_config}" | while read -r fname ; do echo "appending .subst if needed"
      case "${fname}" in 
        *.json) mv "${fname}" "${fname}.subst";;
        *.xml) mv "${fname}" "${fname}.subst";;
        *) echo "skipping: ${fname}" ;;
      esac
    done
    echo "begin replacing..."
    # ls /tmp/data_archive/data
    find "${data_tmp_dir}" -name '*.subst' -print0 | xargs -0 sed -i '' "s/${source_host}/\\$\{${dest_var}\}/g"
    if test "${rename_datazip}" = "true" ; then
      if ! test -d "${in_data_config_fpath}.bak" -o -f "${in_data_config_fpath}.bak" ; then
        cp -r -n "${in_data_config_fpath}" "${in_data_config_fpath}".bak
      else 
        echo " found .bak, avoiding overwrite "
      fi
    fi
    if test -d "${in_data_config_fpath}" -o -f "${in_data_config_fpath}" ; then
      rm -r "${in_data_config_fpath}"
    fi

    if test "${data_tmp_dir}/data" = "${data_to_config}" ; then
      rm -rf "${in_data_config_dir}/_data.zip_"
      rm -rf "${in_data_config_dir}/data"
      mv "${data_to_config}" "${in_data_config_dir}/_data.zip_"
    elif test -f "${data_to_config}.subst" ; then
      mv "${data_to_config}.subst" "${in_data_config_dir}/."
    elif test -f "${data_to_config}" ; then
      mv "${data_to_config}" "${in_data_config_dir}/."
    else 
      echo "error with subst"
      exit 1
    fi
    cd "${_pwd}"
    rm -rf "${data_tmp_dir}"
  else 
    echo "chose not to replace"
    rm -rf "${data_tmp_dir}"
  fi
}

if ! test -z ${env_file} ; then 
  rename_datazip="true"
  is_interactive="false"
  set_vars() {
    source_host="${1}"
    dest_var="${2}"
  }
  while read line || [ -n "$line" ] ; do 
    set_vars ${line}
    prep_variablize
  done < "${env_file}"
else 
  prep_variablize
fi