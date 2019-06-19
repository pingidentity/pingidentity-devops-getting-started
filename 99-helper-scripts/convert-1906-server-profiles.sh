#!/usr/bin/env sh
################################################################################
# Utility script to convert 1906 style pingdirectory server profiles to new
# PingDirectory 7.3 native server profile support.
################################################################################
TOOL_NAME=$( basename "${0}" )
cd "$( dirname "${0}" )" || exit 1

availableProducts="pingfederate pingaccess pingdirectory pingdatasync"
containerInstancePath="/opt/out/instance"

##########################################################################################
usage ()
{
        if ! test -z "${1}" ; then
       echo "-------------------------------------------------------------------------"
           echo "Error: ${1}"
       echo "-------------------------------------------------------------------------"
        fi

        cat <<END_USAGE1

Usage: ${TOOL_NAME} {options}
    where {options} include:
       *-s, --source {server profile source directory}
            Default: current directory
       *-d, --dest {server profile destination directory}
            Default: current directory/pd.profile

END_USAGE1

        exit 77
}


##########################################################################################
srcDir="."
dstDir="./pd.profile"
while ! test -z "${1}" ; do
    case "${1}" in
        -s|--source)
           shift
           test -z "${1}" && usage "source-dir path missing"
           srcDir=${1}
           test ! -d "${srcDir}" && usage "Source Directory '${srcDir}' does not exist.  Please provide new path"
           ;;
        -d|--dest)
           shift
           test -z "${1}" && usage "dest-dir path missing"
           dstDir=${1}
           test -d "${dstDir}" && usage "Destination Directory '${dstDir}' already exists.  Please provide new path"
           ;;
        *)
           usage
    esac
    shift
done

GREEN='\033[0;32m'
NC='\033[0m'

echo_green()
{
    echo "${GREEN}$*${NC}"
}

echo_green "
##########################################################################################
# Converting source-profiles from:
#    Source Dir: ${srcDir}
#      Dest Dir: ${dstDir}
##########################################################################################
"

# Create the skeleton
mkdir -p ${dstDir}
mkdir -p ${dstDir}/dsconfig
mkdir -p ${dstDir}/ldif/userRoot
mkdir -p ${dstDir}/misc-files
mkdir -p ${dstDir}/server-root/pre-setup
mkdir -p ${dstDir}/server-root/post-setup

echo "
# These arguments are passed in to the server's setup tool when manage-profile
# setup is run. The PING_SERVER_ROOT and PING_PROFILE_ROOT variable values are
# provided, but if the PING_INSTANCE_NAME variable is used, it will need to be
# provided through environment variables or a profile variables file passed in
# to the manage-profile tool.
#
# In these example arguments, the PingDirectory.lic license file will need to
# be available in the server root. It can be added to the server-root/pre-setup
# directory in the profile to be copied to the server before these arguments are
# used.
#
# In these example arguments, a password and passphrase file are expected in the
# misc-files directory of the profile. These files would only need to be present
# when manage-profile setup is run and can be deleted after the tool completes.
# An alternative for non-production environments is to not use password files.
# For example, the root user password could be directly provided with the
# --rootUserPassword argument, and the --encryptDataWithRandomPassphrase
# argument can be used to encrypt data with a randomly generated key.
    --verbose \\
    --acceptLicense \\
    --skipPortCheck \\
    --licenseKeyFile \${PING_SERVER_ROOT}/PingDirectory.lic \\
    --location \"\${LOCATION}\" \\
    --instanceName \${HOSTNAME} \\
    --ldapPort \${LDAP_PORT} \\
    --ldapsPort \${LDAPS_PORT} \\
    --httpsPort \${HTTPS_PORT} \\
    --enableStartTLS \\
    \${jvmOptions} \\
    \${certificateOptions} \\
    \${encryptionOption} \\
    --rootUserDN \"\${ROOT_USER_DN}\" \\
    --rootUserPasswordFile \"\${ROOT_USER_PASSWORD_FILE}\" \\
    --baseDN \"\${USER_BASE_DN}\" \\
    --addBaseEntry
" > ${dstDir}/setup-arguments.txt

echo "
Certain steps will always need to be taken to use this generated profile with
the manage-profile tool. The generated profile includes a setup-arguments.txt
file that contains variables, such as ${PING_INSTANCE_NAME}. When using this
profile with the manage-profile tool, values for those variables will need to
be provided using either a profile variables file or environment variables. See
manage-profile setup --help for more information on providing variable values.
In addition, the generated profile does not include any LDIF files. Any desired
LDIF data for the profile will need to be added to the correct backend's
directory under the ldif/ directory (such as ldif/userRoot/ for the userRoot
backend). File-based arguments in setup-arguments.txt, such as
--rootUserPasswordFile, must have the necessary files available when the
profile is run. The provided PING_PROFILE_ROOT and PING_SERVER_ROOT variables
can be used when referring to those files.

Other steps may need to be taken depending on the generated profile. Additional
files can be added to the generated profile, such as server root files, server
SDK extensions, and dsconfig commands. The profile can be modified as necessary
for documentation and organization.

For more information on the server profile, see the example profile template
and README in resource/server-profile-template.zip in the server root.
" > ${dstDir}/misc-files/README

echo "
# This file specifies the relative paths of any files that should not have
# any variables substituted by the manage-profile tool.

misc-files/README
" > ${dstDir}/variables-ignore.txt

for currFile in $( ls "${srcDir}/data" ) ; do
    newFile=${currFile}
    newFile=$(echo $newFile | sed 's/.subst//')
    newFile=$(echo $newFile | sed 's/-userRoot-/-/')

    cp ${srcDir}/data/${currFile} ${dstDir}/ldif/userRoot/${newFile}
done


for currFile in $( ls "${srcDir}/dsconfig" ) ; do
    newFile=${currFile}
    newFile=$(echo $newFile | sed 's/.subst//')

    cp ${srcDir}/dsconfig/${currFile} ${dstDir}/dsconfig/${newFile}
done

cp -r ${srcDir}/instance/* ${dstDir}/server-root/pre-setup/.