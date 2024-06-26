#!/bin/bash
# Install flux and flux-system namespace
kubectl apply -f ../../flux/installation/flux-installation.yaml

# Apply GPG private-key (used to decrypt secrets)
gpg -d cluster-private-key.gpg | kubectl apply -f -

# Apply initial flux-config (gitrepo and root-kustomization)
kubectl apply -f ../../flux/config/flux-config-ks.yaml

# Apply additional flux-config (prod-only)
kubectl apply -f ../../prod/flux/config/prod-flux-config-ks.yaml
