#!/usr/bin/env sh

DOCKER_BUILD_DIR="${HOME}/projects/devops/pingidentity-docker-builds"

#
#
#
append_doc()
{
    echo "$*" >> "${DOCFILE}"
}

#
#
#
append_header()
{
   append_doc ""
}

#
#
#
append_footer()
{
    append_doc ""
    append_doc "---"
    append_doc "This document auto-generated from _[pingidentity/${DOCKERIMAGE} Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/${DOCKERIMAGE}/Dockerfile)_"
    append_doc ""
    append_doc "Copyright (c)  2019 Ping Identity Corporation. All rights reserved."
}

#
#
#
parse_description()
{
    grep "^#-desc " "${DOCKERFILE}" | while read -r line ; do
        append_doc $(echo "$line" | sed 's/^#-desc //')
    done
}

#
#
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
        append_doc "| ------------: | ----------- | -------"
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
parse_dockerfile()
{
    DOCKERFILE="${1}"
    DOCKERIMAGE=$(basename "$(dirname "${DOCKERFILE}")")

    DOCFILE="docker-images/${DOCKERIMAGE}.md"
    rm "${DOCFILE}"

    echo "Parsing Dockerfile ${DOCKERIMAGE}..."
        
    append_header

    cat "${DOCKERFILE}" | while read -r line ; do
        
        #
        # Parse the ENV Description
        #   Example: $-env This is the description
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

    append_footer
}

DFILES=$(find "${DOCKER_BUILD_DIR}" -print | grep Dockerfile)

for DFILE in ${DFILES}
do
    parse_dockerfile "${DFILE}"
done