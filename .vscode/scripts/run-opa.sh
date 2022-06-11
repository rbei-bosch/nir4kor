
echo "#######################################################"
echo "### Running Open Policy Agent                       ###"
echo "#######################################################"

#grpc
#https://github.com/open-policy-agent/opa-envoy-plugin/tree/main/examples/gloo-edge

ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
source $ROOT_DIRECTORY/.vscode/scripts/exec-check.sh "$@" $(basename $BASH_SOURCE .sh)
GITHUB_TOKEN="$ROOT_DIRECTORY/github_token.txt"
OPA_VERSION=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .opa.version | tr -d '"')
OPA_ROOT=$ROOT_DIRECTORY/.vscode/scripts/assets/opa
# Downloading OPA exec
if [[ ! -f "$OPA_ROOT/$OPA_VERSION/opa" ]]
then
    curl -L -o $OPA_ROOT/$OPA_VERSION/opa https://openpolicyagent.org/downloads/$OPA_VERSION/opa_linux_amd64_static --create-dirs
    chmod 755 $OPA_ROOT/$OPA_VERSION/opa
fi

# Download repo with policies
cred=$(cat $GITHUB_TOKEN)
OPA_REPO=https://$cred@github.com/SoftwareDefinedVehicle/open-policy-agent-config.git
git -C $OPA_ROOT/open-policy-agent-config pull || git clone $OPA_REPO $OPA_ROOT/open-policy-agent-config

# Run OPA Server
$OPA_ROOT/$OPA_VERSION/opa run \
--log-level debug \
--authentication=token \
--authorization=basic \
--server \
-c $OPA_ROOT/open-policy-agent-config/opa-config/config.yaml

