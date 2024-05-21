#!/bin/bash
# Create namespace for the CSO
kubectl create namespace cso-system

kubectl create secret generic cso-cluster-stack-variables -n cso-system \
    --from-literal=git-access-token=$GITHUB_TOKEN \
    --from-literal=git-org-name=SovereignCloudStack \
    --from-literal=git-provider=github \
    --from-literal=git-repo-name=cluster-stacks

# Install flux and flux-system namespace
kubectl apply -f ../flux/flux-system/gotk-components.yaml

# Apply initial flux-config (gitrepo and root-kustomization)
kubectl apply  -f ../flux/flux-system/root-ks.yaml
