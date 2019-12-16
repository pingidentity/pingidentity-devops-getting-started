#!/bin/bash
THIS=`basename ${0}`
CMD="${1}"

################################################################################
# Check for a .pingidentity directory with build-server-name.properties
################################################################################
# BUILD_PROPS="${HOME}/.pingidentity/${THIS}.properties"
# test -f "${BUILD_PROPS}" && source "${BUILD_PROPS}"


################################################################################
# Print usage information
################################################################################
function usage()
{
cat <<EO_USAGE

Usage: ${THIS} [ configure ]

       Available options include:

            configure: Prompts user for questions to write properties into
                       '${BUILD_PROPS}' file 

Examples

  Configure the settings for ${THIS} properties

    ${THIS} configure

EO_USAGE

  exit
}

################################################################################
# Startup the docker container and drop the user into it.
################################################################################
run_interactive()
{
    SOURCE_GIT_REPO="https://github.com/pingidentity/pingidentity-server-profiles"

    echo "
##############################################################################################
# This will help build a new server-profile based on the template.
#
#   SOURCE_GIT_REPO: ${SOURCE_GIT_REPO}
#
################################################################################################
    "

    cd "${TMP_DIR}"

    
    while true ; do
        echo "Which repo would you like to start from?"
        echo ""
        echo "   getting-started/pingaccess"
        echo "   getting-started/pingdatagovernance"
        echo "   getting-started/pingdirectory"
        echo "   getting-started/pingfederate"
        echo "   getting-started/pingdatasync"
        echo ""
        echo "   baseline/pingaccess"
        echo "   baseline/pingdatagovernance"
        echo "   baseline/pingdirectory"
        echo "   baseline/pingfederate"
        echo "   baseline/pingdatasync"
        echo ""
        echo -n "Which server-profile would you like to start from []? "
        read -r answer
        
        test -z "${answer}" && continue

        SOURCE_SERVER_PROFILE_DIR="${answer}"

        echo "Checking for server-profile (${SOURCE_SERVER_PROFILE_DIR})..."

        #
        # Clone the source git repo
        #
        if test ! -d source-repo ; then
            git clone ${SOURCE_GIT_REPO} source-repo

            rm -rf source-repo/.git
        fi

        if test ! -d source-repo/${SOURCE_SERVER_PROFILE_DIR} ; then
            echo "Server Profile (${SOURCE_SERVER_PROFILE_DIR}) not found!"
        else
            break
        fi
    done

    echo "
##############################################################################################
# Now we need to get some information on what you want your new Target Github Repo to look
# like.
#
# You will need a Git Personal Access Token to Complete these steps.  You can obtain that
# by logging in to github.com and going to:
#     Settings --> Devloper settings --> Personal access tokens --> Generate new token
#  or
#     https://github.com/settings/tokens
#
# Make sure you generate a token that has repo scopes checked.  And be sure to keep that 
# personal access token.
##############################################################################################
    "

    TARGET_GIT_API="https://api.github.com"
    TARGET_GIT_REPO_NAME="server-profile-pingidentity-test-$$"
    TARGET_SERVER_PROFILE_DIR="${SOURCE_SERVER_PROFILE_DIR}"

    echo -n "Git API. You probably won't need to change this. [${TARGET_GIT_API}] ? "
    read answer
    ! test -z "${answer}" && TARGET_GIT_API="${answer}"

    echo -n "Target GIT Repo URL [${TARGET_GIT_REPO}] ? "
    read answer
    ! test -z "${answer}" && TARGET_GIT_REPO="${answer}"

    echo -n "Target GIT Personal Access Token [${TARGET_GIT_ACCESS_TOKEN}] ? "
    read answer
    ! test -z "${answer}" && TARGET_GIT_ACCESS_TOKEN="${answer}"


    #
    # Trying to create a priviate repo using the GIT Api and the Users ACCESS Token
    #
    CURL_RESULT=$( curl \
        -G \
        -H "Content-Type:application/json" \
        -d "affiliation=owner" \
        -H "Authorization: token ${TARGET_GIT_ACCESS_TOKEN}" \
        -w '%{http_code}' \
        -o "${TMP_DIR}/repos" \
        "${TARGET_GIT_API}/user/repos" \
        2> /dev/null )
    
    if test "${CURL_RESULT}" == "200" ; then
        echo ""
        echo "Availble Repositories for ${TARGET_GIT_REPO}"
        cat "${TMP_DIR}/repos" | jq -r '.[].name' | sed 's/^/        /'
        echo ""
    fi

    echo "Which project/repo would you like to use, "
    echo -n "   or if new, type in a new name [${TARGET_GIT_REPO_NAME}] ? "
    read answer
    ! test -z "${answer}" && TARGET_GIT_REPO_NAME="${answer}"

    echo -n "What would you like to name your server-profile within the repo [${TARGET_SERVER_PROFILE_DIR}] ? "
    read answer
    ! test -z "${answer}" && TARGET_SERVER_PROFILE_DIR="${answer}"


    TARGET_GIT_REPO_URL="${TARGET_GIT_REPO}/${TARGET_GIT_REPO_NAME}"

        echo "
##############################################################################################
# We are about to create a new repo, or update your existing copying the server profile.
#
#       SOURCE_REPO: ${SOURCE_GIT_REPO}/${SOURCE_SERVER_PROFILE_DIR}
#
#       TARGET_REPO: ${TARGET_GIT_REPO_URL}/${TARGET_SERVER_PROFILE_DIR}
#
##############################################################################################

          Hit Enter to continue, otherwise <ctrl-c> to cancel...
    "
    read -r answer

    #
    # Trying to create a priviate repo using the GIT Api and the Users ACCESS Token
    #
    CURL_RESULT=$( curl \
        -H "Content-Type:application/json" \
        -H "Authorization: token ${TARGET_GIT_ACCESS_TOKEN}" \
        -w '%{http_code}' \
        -d '{"name":"'${TARGET_GIT_REPO_NAME}'","private": true}' \
        -o /dev/null \
        "${TARGET_GIT_API}/user/repos" \
        2> /dev/null )

    #
    # If a 201 is returned, then it's succesfully created
    #
    if test "${CURL_RESULT}" == "201" ; then
        echo "New repo '${TARGET_GIT_REPO_URL}/${TARGET_GIT_REPO_NAME}' created"

        mkdir -p "${TARGET_GIT_REPO_NAME}/${TARGET_SERVER_PROFILE_DIR}"

        (cd source-repo/${SOURCE_SERVER_PROFILE_DIR}; tar cf - ./* ) | (cd ${TARGET_GIT_REPO_NAME}/${TARGET_SERVER_PROFILE_DIR}; tar xf -)

        cd "${TARGET_GIT_REPO_NAME}"
    
        git init

        TARGET_GIT_WITH_TOKEN="${TARGET_GIT_REPO/\:\/\//://$TARGET_GIT_ACCESS_TOKEN@}"
        git remote add origin ${TARGET_GIT_WITH_TOKEN}/${TARGET_GIT_REPO_NAME}

    fi

    #
    # If a 422 is returned, then it's succesfully created
    #
    if test "${CURL_RESULT}" == "422" ; then
        echo "Existing repo '${TARGET_GIT_REPO_URL}/${TARGET_GIT_REPO_NAME}' used"
        git clone "${TARGET_GIT_REPO_URL}"

        mkdir -p "${TARGET_GIT_REPO_NAME}/${TARGET_SERVER_PROFILE_DIR}"

        (cd source-repo/${SOURCE_SERVER_PROFILE_DIR}; tar cf - ./* ) | (cd ${TARGET_GIT_REPO_NAME}/${TARGET_SERVER_PROFILE_DIR}; tar xf -)

        cd "${TARGET_GIT_REPO_NAME}"
    fi

    git add .
    git commit -m "Initial commit from ${THIS}"
    git push -u origin master 

  
    echo "
##############################################################################################
# Congratulations!!!
#
# Your repo has been created and/or updated.
##############################################################################################
    "

    $(which tree)
}


TMP_DIR=$(mktemp -d)

echo "Using TMP_DIR ({$TMP_DIR})"

test -z "${CMD}" && run_interactive

rm -rf ${TMP_DIR}

