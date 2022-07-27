# AKS Falco Benchmark

## Overview

This guide showcases how to install a falco benchmark tool in AKS with FluxCD.

## Requirements

To run with `bootstrap.sh` script, the following CLI tools need to be installed:
- terraform
- az
- gh
- flux

## Infrastructure

Before you do anything, please check the following:

- Fork this repo into your github account
- Check `bootstrap.sh` and change your github user and any other local variables you need.
- Check `terraform/terraform.tfvars` and change to whichever defaults you prefer.

Login with your azure account:
```sh
az login
```

Login with your github:
```sh
gh auth login

# Retrieve the github token
gh auth status -t

# Copy it to the environment var
export GITHUB_TOKEN=<token>
```

Then run the `bootstrap.sh` script:
```sh
./bootstrap.sh
```

The `bootstrap.sh`:
- Creates an AKS cluster with `terraform` CLI.
- Installs `FluxCD` with the `flux` CLI.
- Through `FluxCD`, installs the `Falco` charts.


## References

https://stacksimplify.com/azure-aks/create-aks-cluster-using-terraform
