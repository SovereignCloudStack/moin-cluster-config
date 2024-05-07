#!/bin/bash
# Install flux and flux-system namespace
kubectl apply -f ../flux/flux-system/gotk-components.yaml

# Apply GPG private-key (used to decrypt secrets)
gpg -d cluster-private-key.gpg | kubectl apply -f -

# Apply initial flux-config (gitrepo and root-kustomization)
kubectl apply  -f ../flux/flux-system/root-ks.yaml
