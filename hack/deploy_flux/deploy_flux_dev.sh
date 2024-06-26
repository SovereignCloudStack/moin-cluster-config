#!/bin/bash
# Create namespace for the CSO
kubectl create namespace cso-system

# Create the config for the CSO
kubectl create secret generic cso-cluster-stack-variables -n cso-system \
	--from-literal=git-access-token=$GITHUB_TOKEN \
	--from-literal=git-org-name=SovereignCloudStack \
	--from-literal=git-provider=github \
	--from-literal=git-repo-name=cluster-stacks

# Create namespace for the CSPO
kubectl create namespace cspo-system

# Create the config for the CSPO
kubectl create secret generic cspo-cluster-stack-variables -n cspo-system \
	--from-literal=git-access-token=$GITHUB_TOKEN \
	--from-literal=git-org-name=SovereignCloudStack \
	--from-literal=git-provider=github \
	--from-literal=git-repo-name=cluster-stacks

# Install flux and flux-system namespace
kubectl apply -f ../../flux/installation/flux-installation.yaml

# Apply initial flux-config (gitrepo and root-kustomization)
kubectl apply -f ../../flux/config/flux-config-ks.yaml
