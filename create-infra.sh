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

function create_infra()
{
    local -r resource_group="${1}"; shift;
    local -r cluster_name="${1}"; shift;
    local -r tf_folder="${1}"; shift;

    #local -r current_path=$(pwd)
    (
        cd "${tf_folder}" \
        && terraform init \
        && terraform apply \
            -var="resource_group_name=${resource_group}" \
            -var="cluster_name=${cluster_name}" \
            -auto-approve
        #&& cd "${current_path}"
    )
}

function get_credentials()
{
    local -r resource_group="${1}"; shift;
    local -r cluster_name="${1}"; shift;

    az aks get-credentials --admin -g "${resource_group}" -n "${cluster_name}" --overwrite-existing
}

function main()
{
    local -r resource_group="${1}"; shift;
    local -r cluster_name="${1}"; shift;
    local -r tf_folder="${1}"; shift;

    # Check first if any CLI tool is missing.
    local -r prerequisites=("terraform" "az")
    check_prerequisites "${prerequisites}"

    create_infra "${resource_group}" "${cluster_name}" "${tf_folder}"
    get_credentials "${resource_group}" "${cluster_name}"
}

main "${@}"
