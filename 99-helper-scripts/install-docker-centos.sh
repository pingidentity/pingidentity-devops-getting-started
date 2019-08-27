#!/usr/bin/env sh
#################################################################################
# Utility script to install dependencies used in DevOps environment on Centos 7.6
# Tools installed: 
#   - Docker
#   - docker-compose
#   - jq
#   - jwt
#   - AWS CLI
#   - Google Cloud SDK
#   - Azure CLI
#   - Ping Identity DevOps Repos
#
# Execute this script using sudo
# Ex. sudo ./install-devops-tooling-centos.sh
#################################################################################
GREEN='\033[0;32m'
NC='\033[0m'

echo_header() 
{
    echo "########################################################"
    echo "# $*"
    echo "########################################################"
}

# Check for the existence of a tool command
check_for_tool()
{
    toolName="${1}" && shift
    toolCmd="${1}" && shift
    installFunction="${1}" && shift
    
    ${toolCmd} 2>/dev/null >/dev/null
    RESULT=$?

    if test "${RESULT}" = '127'; then
        # Tool does not exist, install
        $installFunction
    else
        echo_header " $toolName already installed"
    fi
}

install_docker()
{
    # Install Docker
    echo_header " Installing Docker..."
    sudo yum update
    sudo yum install yum-utils device-mapper-persistent-data lvm2
    sudo yum install docker-ce
}

install_docker_compose()
{
    #Current docker-compose version
    dc_version=1.24.1
    # Install docker-compose
    echo_header " Installing docker-compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/${dc_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

install_jq()
{
    # Install jq
    echo_header " Installing jq..."
    sudo yum install jq -y
}

install_jwt()
{
    # Install jwt
    echo_header " Installing jwt..."
    sudo yum install python-jwt -y
}

install_aws_cli()
{
    # Install aws cli
    echo_header " Installing AWS CLI..."
    sudo pip install --upgrade pip
    sudo pip install awscli
    pip install awscli --upgrade --user
}

install_eksctl()
{
    # Install eksctl
    echo_header " Installing eksctl..."
    echo "Downloading eksctl"
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    echo "Moving eksctl to /usr/local/bin"
    sudo mv /tmp/eksctl /usr/local/bin
}

install_gcloud_sdk()
{
    # Install gcloud sdk
    # Add the Cloud SDK distribution URI as a package source
    echo_header " Installing Google Cloud SDK..."
    cat <<EOF > /etc/yum.repos.d/google-cloud-sdk.repo  
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

    sudo yum install google-cloud-sdk -y
}

install_azure_cli()
{
    # Install Azure CLI
    echo_header " Installing Azure CLI..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
    sudo yum install azure-cli -y
}

install_kubectl() 
{
    # Install kubectl
    echo_header " Installing kubectl..."
   cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

    sudo yum install -y kubelet kubeadm kubectl
    systemctl enable --now kubelet
}

function install_pip()
{
    # Install pip
    echo_header " Installing PIP..."
    sudo yum install epel-release
    sudo yum install -y python-pip
    #upgrade pip
    sudo pip install --upgrade pip
}

clone_devops_projects()
{
    DIR_NAME="/home/centos/projects/devops"
    BASH_PROFILE="/home/centos/.bash_profile"

    # Determine if projects already exist
    if test -d "${DIR_NAME}"; then 
        echo_header " Ping Identity Devops GitHub projects already available @ ${DIR_NAME}"
    else
        echo_header " Cloning Ping Identity Github repos..."
        mkdir -p ${DIR_NAME}
        cd ${DIR_NAME}

        git clone "https://github.com/pingidentity/pingidentity-devops-getting-started.git" 
        git clone "https://github.com/pingidentity/pingidentity-docker-builds.git"
        git clone "https://github.com/pingidentity/pingidentity-server-profiles.git"
    fi
}

# Install Docker if not already present
check_for_tool "PIP" "pip --version" "install_pip"
check_for_tool "Docker" "docker -v" "install_docker"
check_for_tool "Docker-compose" "docker-compose -v" "install_docker_compose"
check_for_tool "JQ" "jq -V" "install_jq"
check_for_tool "JWT" "pyjwt -V" "install_jwt"
check_for_tool "AWS CLI" "aws --version" "install_aws_cli"
check_for_tool "Eksctl" "eksctl version" "install_eksctl"
check_for_tool "GCloud SDK" "gcloud -v" "install_gcloud_sdk"
check_for_tool "Azure CLI" "az -V" "install_azure_cli"
check_for_tool "Kubectl" "kubectl version" "install_kubectl"

# Clone Ping Identity Repos, setup docker aliases
clone_devops_projects
