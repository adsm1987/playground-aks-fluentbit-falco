#! /usr/bin/env bash

# abort on nonzero exitstatus
set -o errexit

# abort on unbound variable
set -o nounset

# don't hide errors within pipes
set -o pipefail

function check_prerequisites()
{
    local -r prerequisites="${@}"

    for item in "${prerequisites[@]}"; do
        if [[ -z $(which "${item}") ]]; then
            echo "${item} cannot be found on your system, please install ${item}"
            exit 1
        fi
    done
}

function main()
{
    local -r prerequisites=("terraform" "az" "flux" "gh")

    local -r infra_resource_group="playground-aks-falco"
    local -r infra_cluster_name="aks-falco"
    local -r infra_tf_folder="terraform"
    local -r flux_github_user="deeproute"
    local -r flux_github_repo="playground-aks-falco"
    local -r flux_github_path="./fluxcd/clusters/aks"

    echo "To run this script you need the following CLIs installed:"
    echo "- terraform"
    echo "- az - Azure CLI"
    echo "- flux - FluxCD to sync the helm charts of Vault"
    echo "- gh - github CLI to authenticate with the GitHub repo"
    echo ""
    echo "You also need to specify your fluxcd github repo which you can fork based from this URL:"
    echo "https://github.com/deeproute/playground-aks-falco"
    echo ""
    read -r -p "Press enter to continue"

    # Check first if any CLI tool is missing. 
    check_prerequisites "${prerequisites}"

    echo ""
    echo "The bootstrap has the below defined vars. Change to your needs."
    echo "Infra Resource Group: ${infra_resource_group}"
    echo "Infra Cluster Name: ${infra_cluster_name}"
    echo "Infra Terraform Folder: ${infra_tf_folder}"
    echo "GitHub User/Owner: ${flux_github_user}"
    echo "GitHub Repo: ${flux_github_repo}"
    echo "GitHub Path: ${flux_github_path}"
    echo ""

    read -r -p "Press enter to continue or CTRL+C to abort to change the vars."

    ./script-run.sh "${infra_resource_group}" \
              "${infra_cluster_name}" \
              "${infra_tf_folder}" \
              "${flux_github_user}" \
              "${flux_github_repo}" \
              "${flux_github_path}"
}

main "${@}"
