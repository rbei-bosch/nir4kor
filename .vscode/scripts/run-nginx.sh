
echo "#######################################################"
echo "### Running nginx-static                            ###"
echo "#######################################################"


ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
source $ROOT_DIRECTORY/.vscode/scripts/exec-check.sh "$@" $(basename $BASH_SOURCE .sh)
GITHUB_TOKEN="$ROOT_DIRECTORY/github_token.txt"
OPA_ROOT=$ROOT_DIRECTORY/.vscode/scripts/assets/opa


# Download repo with policies
cred=$(cat $GITHUB_TOKEN)
OPA_REPO=https://$cred@github.com/SoftwareDefinedVehicle/open-policy-agent-config.git
git -C $OPA_ROOT/open-policy-agent-config pull || git clone $OPA_REPO $OPA_ROOT/open-policy-agent-config

cd $OPA_ROOT/open-policy-agent-config
./bundle-release.sh 
docker stop $(docker ps -q --filter ancestor=flashspys/nginx-static )
docker run -v $OPA_ROOT/open-policy-agent-config/bundle:/static -p 8080:80 flashspys/nginx-static