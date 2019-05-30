#!/usr/bin/env sh
cd "$( dirname "${0}" )"
THIS="$( basename "${0}" )"
THIS_DIR=`pwd`


DOCKER_BUILD_DIR="${HOME}/projects/devops/pingidentity-docker-builds"

#
# Usage printing function
#
usage ()
{
cat <<END_USAGE
Usage: ${THIS} {options}
    where {options} include:

    -d, --docker-image {docker-image}
        The name of the docker image to build dos for
    -h, --help
        Display general usage information
END_USAGE
exit 99
}

#
# Append all arguments to the end of the current markdown document file
#
append_doc()
{
    echo "$*" >> "${_docFile}"
}

#
# Append a header
#
append_header()
{
   append_doc ""
}

#
# Append a footer including a link to the source file
#
append_footer()
{
    _srcFile="${1}"

    append_doc ""
    append_doc "---"
    append_doc "This document auto-generated from _[${_srcFile}](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/${_srcFile})_"
    append_doc ""
    append_doc "Copyright (c)  2019 Ping Identity Corporation. All rights reserved."
}

#
# Start the section on environment variables
#
append_env_table_header()
{
    if test "${ENV_TABLE_ACTIVE}" != "true" ; then
        ENV_TABLE_ACTIVE="true"

        append_doc "## Environment Variables"
        append_doc "The following environment \`ENV\` variables can be used with "
        append_doc "this image. "
        append_doc ""

        append_doc "| ENV Variable  | Default     | Description"
        append_doc "| ------------: | ----------- | ---------------------------------"
    fi
}

#
#
#
append_env_variable()
{
    envVar=${1} && shift
    envDesc=${1} && shift
    envDef=${1} && shift

    append_doc "| ${envVar}  | ${envDef}  | ${envDesc}"
}

#
#
#
append_expose_ports()
{
    exposePorts=${1}

    append_doc "## Ports Exposed"
    append_doc "The following ports are exposed from the container.  If a variable is"
    append_doc "used, then it may come from a parent container"

    for port in ${exposePorts}; do
        append_doc "- $port"
    done

    append_doc ""
}

#
#
#
parse_hooks()
{
    _dockerImage="${1}"
    _hooksDir="${DOCKER_BUILD_DIR}/${_dockerImage}/hooks"

    mkdir -p "docker-images/${_dockerImage}/hooks"

    echo "Parsing hooks for ${_dockerImage}..."
    
    _hookFiles=""

    for _hookFile in $(ls ${_hooksDir}); do
        _hookFiles="${_hookFiles} ${_hookFile}"
        _docFile="docker-images/${_dockerImage}/hooks/${_hookFile}.md"
        rm -f "${_docFile}"
        echo "  parsing hook ${_hookFile}"
        append_header
        append_doc "# Ping Identity DevOps \`${_dockerImage}\` Hook - \`${_hookFile}\`"

        cat "${_hooksDir}/${_hookFile}" | while read -r line ; do
            #
            # Parse the remaining lines for "#-"
            #
            if [ "$(echo "${line}" | cut -c-2)" = "#-" ] ; then
                md=$(echo "$line" | sed \
                 -e 's/^\#- //' \
                 -e 's/^\#-$//')

                append_doc "$md"
            fi
        done

        append_footer "${_dockerImage}/hooks/${_hookFile}"
    done


    _docFile="docker-images/${_dockerImage}/hooks/README.md"
    rm -f ${_docFile}
    append_header
    append_doc "# Ping Identity DevOps \`${_dockerImage}\` Hooks"
    append_doc "List of available hooks:"
    for _hookFile in ${_hookFiles}; do
        append_doc "* [${_hookFile}](${_hookFile}.md)"
    done
    append_footer "${_dockerImage}/hooks"
}

#
#
#
parse_dockerfile()
{
    _dockerImage="${1}"
    _dockerFile="${DOCKER_BUILD_DIR}/${_dockerImage}/Dockerfile"
 
    mkdir -p "docker-images/${_dockerImage}"

    _docFile="docker-images/${_dockerImage}/README.md"
    rm -f "${_docFile}"

    echo "Parsing Dockerfile ${_dockerImage}..."
        
    append_header

    cat "${_dockerFile}" | while read -r line ; do
        
        #
        # Parse the ENV Description
        #   Example: $-- This is the description
        #
        if [ "$(echo "${line}" | cut -c-3)" = "#--" ]; then
            ENV_DESCRIPTION="${ENV_DESCRIPTION}$(echo "${line}" | cut -c5-) "
            continue
        fi

        #
        # Parse the ENV Description
        #   Example: ENV VARIABLE=value
        #
        if [ "$(echo "${line}" | cut -c-4)" = "ENV " ] ||
           [ "$(echo "${line}" | cut -c-12)" = "ONBUILD ENV " ]; then
            ENV_VARIABLE=$(echo "${line}" | sed -e 's/=/x=x/' -e 's/^.*ENV \(.*\)x=x.*/\1/')
            ENV_VALUE=$(echo "${line}" | sed -e 's/=/x=x/' -e 's/^.*x=x\(.*\)/\1/' -e 's/^"\(.*\)"$/\1/')
            
            append_env_table_header

            append_env_variable "${ENV_VARIABLE}" "${ENV_DESCRIPTION}" "${ENV_VALUE}"
            ENV_DESCRIPTION=""
        
            continue
        fi

        #
        # Parse the EXPOSE values
        #   Example: EXPOSE PORT1 PORT2
        #
        if [ "$(echo "${line}" | cut -c-7)" = "EXPOSE " ] ||
           [ "$(echo "${line}" | cut -c-15)" = "ONBUILD EXPOSE " ]; then
            EXPOSE_PORTS=$(echo "${line}" | sed 's/^.*EXPOSE \(.*\)$/\1/')
    
            append_expose_ports "${EXPOSE_PORTS}"

            continue
        fi

        #
        # Parse the remaining lines for "#-"
        #
        if [ "$(echo "${line}" | cut -c-2)" = "#-" ] ; then
            ENV_TABLE_ACTIVE="false"

            md=$(echo "$line" | sed \
             -e 's/^\#- //' \
             -e 's/^\#-$//')

            append_doc "$md"
        fi
    done

    append_doc "## Docker Container Hook Scripts"
    append_doc "Please go [here](hooks/README.md) for details on all `${_dockerImage}` hook scripts"
    append_footer "${_dockerImage}/Dockerfile"
}

#
# main
#
dockerImages="pingaccess pingfederate pingdirectory pingdatasync
pingbase pingcommon pingdatacommon
pingdataconsole pingdownloader ldap-sdk-tools 
pingdirectoryproxy pingdelegator apache-jmeter"
#
# Parse the provided arguments, if any
#
while ! test -z "${1}" ; do
    case "${1}" in
        -d|--docker-image)
            shift
            if test -z "${1}" ; then
                echo "You must provide name of docker-image(s)"
                usage
            fi
            dockerImages="${1}"
            ;;
        
        --help)
            usage
            ;;
        *)
            echo "Unrecognized option"
            usage
            ;;
    esac
    shift
done

for dockerImage in ${dockerImages}
do
    echo "Creating docs for '${dockerImage}'"

    test ! -d "${DOCKER_BUILD_DIR}/${dockerImage}" \
        && echo "Docker Image '${dockerImage}' not found"

    parse_dockerfile "${dockerImage}"
    parse_hooks "${dockerImage}"
done