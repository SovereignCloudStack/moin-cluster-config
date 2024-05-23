#!/bin/bash
# Create namespace for the CSO
kubectl create namespace cso-system

# Install flux and flux-system namespace
kubectl apply -f ../../flux/installation/flux-installation.yaml

# Apply GPG private-key (used to decrypt secrets)
gpg -d cluster-private-key.gpg | kubectl apply -f -

# Apply initial flux-config (gitrepo and root-kustomization)
kubectl apply  -f ../../flux/config/flux-config-ks.yaml
