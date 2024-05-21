# moin-cluster-config
```
kind create cluster
export GITHUB_TOKEN=<GITHUB pat>
cd deploy_flux
sh deploy_flux.sh
```

Wait very long

For each tenant do
```
helm upgrade -i csp-helper-my-tenant -n my-tenant --create-namespace https://github.com/SovereignCloudStack/openstack-csp-helper/releases/latest/download/openstack-csp-helper.tgz -f path/to/clouds.yaml
```
