#!/usr/bin/env sh
################################################################################
# Utility script to install dependencies used in DevOps environment
# Tools installed: 
#   - Docker
#   - docker-compose
#   - jq
#   - jwt
#   - AWS CLI
#   - Google Cloud SDK
#   - Azure CLI
#   - Ping Identity DevOps Repos
################################################################################

GREEN='\033[0;32m'
NC='\033[0m'

echo_green()
{
    echo "${GREEN}$*${NC}"
}

# Install Docker
echo_green "Installing Docker..."
sudo apt-get update
sudo apt install docker.io -y
# Set Docker to startup on server startup
sudo systemctl start docker
sudo systemctl enable docker

# Install docker-compose
echo_green "Installing docker-compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod 777 /usr/local/bin/docker-compose

# Assign permissions for the ubuntu user
echo_green "Adding docker priviledges to ubuntu user"
sudo usermod -aG docker ubuntu

# Install jq
echo_green "Installing jq..."
sudo add-apt-repository ppa:eugenesan/ppa -y
sudo apt-get update
sudo apt install jq -y

# Install jwt
echo_green "Installing jwt..."
sudo apt install python-jwt -y

# Install aws cli
echo_green "Installing AWS CLI..."
sudo apt install python-pip -y
sudo pip install awscli 

# Install eksctl
echo_green "Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install gcloud sdk
# Add the Cloud SDK distribution URI as a package source
echo_green "Installing Google Cloud SDK..."
echo "deb http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Update the package list and install the Cloud SDK
sudo apt-get update
sudo apt install google-cloud-sdk -y

# Install Azure CLI
echo_green "Installing Azure CLI..."
sudo apt-get update
sudo apt-get install curl apt-transport-https lsb-release gnupg -y

curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg >/dev/null

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update
sudo apt-get install azure-cli -y

# Install kubectl
echo_green "Installing kubectl..."
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Clone Ping's Getting started repos
echo_green "Cloning Ping Identity Github repos..."
BASEDIR="/home/ubuntu/projects/devops"
mkdir -p $BASEDIR
cd $BASEDIR

git clone "https://github.com/pingidentity/pingidentity-devops-getting-started.git" 
git clone "https://github.com/pingidentity/pingidentity-docker-builds.git"
git clone "https://github.com/pingidentity/pingidentity-server-profiles.git"

cd pingidentity-devops-getting-started

if [ ! -e /home/ubuntu/.bash_profile ]
then
   echo "Creating bash_profile"
   touch /home/ubuntu/.bash_profile
fi

./setup

echo_green "Please note you will need to re-login for Docker permissions to take effect."