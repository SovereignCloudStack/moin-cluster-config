# moin-cluster-config
This repo uses flux, Cluster-API, cluster-stacks, Kyverno and a few other components to turn a Kubernetes cluster into a Kubernetes service, where you can apply your desired clusters in Cluster-APIs format and retrieve kubeconfigs to access the deployed and managed clusters. 

The moin-cluster can be used as a quickly disposable dev-setup, a long running production cluster or, even shorter-lived, in a CI run.

## Usage 

If you want to use a deployed and managed version, you can access the moin-cluster with the following kubeconfig.

You also need to have [`oidc-login`](https://github.com/int128/kubelogin) installed on your machine.

`kubeconfig.yaml`

```yaml
apiVersion: v1
clusters:
- cluster:
    server: https://moin.k8s.scs.community
  name: moin-cluster
contexts:
- context:
    cluster: moin-cluster
    user: oidc
  name: moin-cluster
current-context: moin-cluster
kind: Config
users:
- name: oidc
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - oidc-login
      - get-token
      - --oidc-issuer-url=https://dex.k8s.scs.community
      - --oidc-client-id=kubectl
      - --oidc-extra-scope=groups,profile
      command: kubectl
```

If you then run `kubectl get pods --kubeconfig=kubeconfig.yaml` you are redirected to the browser to login via GitHub and after that you can use it as usual.

* Generate a `cluster.yaml` with [`cluster-gen.moin.k8s.scs.community`](https://cluster-gen.moin.k8s.scs.community/) and apply it with `kubectl apply -f cluster.yaml`
* Check the reconciliation progress with our an instance of `capi-visualizer`, which you can access on [`viz.moin.k8s.scs.community`](https://viz.moin.k8s.scs.community).

## Setup

The config is split into two use-cases, prod and dev.

The dev is intended for those who want to start quickly on their local machine. List of components:

- cert-manager
- CAPI
- CAPO
- CSO
- capi-visualizer

The prod components include all of the above and additionally include:
- external-dns
- ingress controller
- lets-encrypt issuer
- RBAC roles
- Kyverno policies
- secrets for gx-scs, dns, github
- pre-deployed namespaces with secrets

### Development setup

To start you need a Kubernetes cluster, you can do that for example with kind:
```
kind create cluster
```

Next you need to have a GitHub token. The token will be used by the CSO to fetch GitHub releases that contain the cluster-stacks (cluster-classes and addons).
```
export GITHUB_TOKEN=<GITHUB pat>
```

The following script will use the GitHub token to create a secret. Further, flux is deployed and configured with a pointer to this repo. This will deploy and configure all relevant components.

```
cd hack/deploy_flux
sh deploy_flux_dev.sh 
```

### Production setup

To start you also need a Kubernetes cluster, ideally not kind. If you want to make use of the RBAC rules, you need to configure oidc.
The GitHub token is not required as it is included as an encrypted secret.

```
cd hack/deploy_flux
sh deploy_flux_prod.sh 
```

Now it will take some time to reconcile all resources, you can either watch flux and Kubernetes doing its work or continue with the next step.

For the following step you need your OpenStack credentials as a yaml-file. You feed the yaml file to the openstack-csp-helper chart with the following command.
```
helm upgrade -i csp-helper-my-tenant -n my-tenant --create-namespace https://github.com/SovereignCloudStack/openstack-csp-helper/releases/latest/download/openstack-csp-helper.tgz -f path/to/openstack-clouds.yaml
```
If the namespace where you deploy the openstack-csp-helper to contains the string "tenant" (like in the example "my-tenant"), a clusterstack, and therefore also a clusterclass is deployed automatically in that namespace. Which brings us to the second to last step. Apply your cluster resource:

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: cs-cluster
  namespace: my-tenant
  labels:
    managed-secret: cloud-config
spec:
  clusterNetwork:
    pods:
      cidrBlocks:
        - 192.168.0.0/16
    serviceDomain: cluster.local
    services:
      cidrBlocks:
        - 10.96.0.0/12
  topology:
    variables:
      - name: controller_flavor
        value: "SCS-2V-4-50"
      - name: worker_flavor
        value: "SCS-2V-4-50"
      - name: external_id
        value: "ebfe5546-f09f-4f42-ab54-094e457d42ec" # gx-scs
    class: openstack-scs-1-27-v4
    controlPlane:
      replicas: 1
    version: v1.29.3
    workers:
      machineDeployments:
        - class: openstack-scs-1-27-v4
          failureDomain: nova
          name: openstack-scs-1-27-v4
          replicas: 1
EOF
```
After the new cluster resource has been reconciled you can retrieve the kubeconfig and communicate with your new cluster:

```
# Get the workload cluster kubeconfig
kubectl get secret -n my-tenant cs-cluster-kubeconfig -o go-template='{{.data.value|base64decode}}' > kubeconfig.yaml

# Communicate with the workload cluster
kubectl --kubeconfig kubeconfig.yaml get nodes
```
