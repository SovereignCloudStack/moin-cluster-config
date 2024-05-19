#!/bin/bash
# Install flux and flux-system namespace
kubectl apply -f ../flux/flux-system/gotk-components.yaml

# Choose your weapon:
#
# You have to provide a clouds.yaml, you have 3 options, choose one:
#
# 1. a demo clouds.yaml with invalid credentials
kubectl create secret generic -n flux-system secret-values --from-file=values.yaml=demo-clouds.yaml
# 
# 2. bring your own valid clouds.yaml
# kubectl create secret generic -n flux-system secret-values --from-file=values.yaml=my-clouds.yaml
#
# 3. use the included (encrypted) valid clouds.yaml (works only if you have access to one of the private-keys the file is encrypted with)
# yq -i '.resources += ["secret.yaml"]' ../flux/csp-helper/kustomization.yaml
# yq -i '.spec.decryption.provider="sops" | .spec.decryption.secretRef.name="sops-gpg"' ../flux/flux-system/flux-kustomizations/csp-helper.yaml
# git add ../flux/csp-helper/kustomization.yaml ../flux/flux-system/flux-kustomizations/csp-helper.yaml>
# git commit -s -m "Use sops to use the encrypted clouds.yaml"
# gpg -d cluster-private-key.gpg | kubectl apply -f -

# Apply initial flux-config (gitrepo and root-kustomization)
kubectl apply  -f ../flux/flux-system/root-ks.yaml
