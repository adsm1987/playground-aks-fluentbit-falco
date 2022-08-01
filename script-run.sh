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
    local -r infra_resource_group="${1}"; shift;
    local -r infra_cluster_name="${1}"; shift;
    local -r infra_tf_folder="${1}"; shift;
    local -r flux_github_user="${1}"; shift;
    local -r flux_github_repo="${1}"; shift;
    local -r flux_github_path="${1}"; shift;

    # Check first if any CLI tool is missing.
    local -r prerequisites=("terraform" "az" "flux" "gh")
    check_prerequisites "${prerequisites}"

    # Create the AKS cluster
    ./create-infra.sh "${infra_resource_group}" "${infra_cluster_name}" "${infra_tf_folder}"
    
    # Get secrets before installing flux
    log_app_name=logs-aks
    workspace_id=$(az monitor log-analytics workspace show -g "${infra_resource_group}" -n "${log_app_name}" --query customerId -o tsv)
    shared_key=$(az monitor log-analytics workspace get-shared-keys -g "${infra_resource_group}" -n "${log_app_name}" --query primarySharedKey -o tsv)
    
    namespace=fluent-bit
    kubectl create namespace "${namespace}" --dry-run=client -o yaml | kubectl apply -f -
    
    kubectl -n "${namespace}" create secret generic fluentbit-secrets \
        --save-config \
        --dry-run=client \
        --from-literal=WorkspaceId="${workspace_id}" \
        --from-literal=SharedKey="${shared_key}" \
        -o yaml | \
        kubectl apply -f -
    # kubectl -n "${namespace}" create secret generic fluentbit-secrets \
    #     --from-literal=WorkspaceId="${workspace_id}" \
    #     --from-literal=SharedKey="${shared_key}"

    # Install FluxCD
    ./fluxcd-install.sh "${flux_github_user}" "${flux_github_repo}" "${flux_github_path}"
}

main "${@}"
