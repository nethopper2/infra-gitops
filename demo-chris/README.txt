# Source: https://gist.github.com/2f6ef41745fad5bf0d7c023c1261d77c

###########################################################################
# How To Shift Left Infrastructure Management Using Crossplane Composites #
# https://youtu.be/AtbS1u2j7po                                            #
###########################################################################

# Referenced videos:
# - Crossplane - GitOps-based Infrastructure as Code through Kubernetes API: https://youtu.be/n8KjVmuHm7A
# - How to apply GitOps to everything - combining Argo CD and Crossplane: https://youtu.be/yrj4lmScKHQ
# - K3d - How to run Kubernetes cluster locally using Rancher k3s: https://youtu.be/mCesuGk-Fks

#########
# Setup #
#########

git clone https://github.com/vfarcic/crossplane-composite-demo.git

cd crossplane-composite-demo

cp cluster-orig.yaml cluster.yaml

# Install Crossplane CLI from https://crossplane.io/docs/v1.3/getting-started/install-configure.html#start-with-a-self-hosted-crossplane

# Please watch https://youtu.be/mCesuGk-Fks if you are not familiar with k3d
# Feel free to use any other Kubernetes platform
k3d cluster create --config k3d.yaml

kubectl create namespace team-a

helm repo add crossplane-stable \
    https://charts.crossplane.io/stable

helm repo update

helm upgrade --install \
    crossplane crossplane-stable/crossplane \
    --namespace crossplane-system \
    --create-namespace \
    --wait

kubectl apply --filename definition.yaml

#############
# Setup AWS #
#############

# Replace `[...]` with your access key ID`
export AWS_ACCESS_KEY_ID=[...]

# Replace `[...]` with your secret access key
export AWS_SECRET_ACCESS_KEY=[...]

echo "[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
" | tee aws-creds.conf

kubectl --namespace crossplane-system \
    create secret generic aws-creds \
    --from-file creds=./aws-creds.conf

kubectl crossplane install provider \
    crossplane/provider-aws:v0.19.0

# Wait for a few moments for the provider to be up-and-running

echo "apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: creds" \
    | kubectl apply --filename -

kubectl apply --filename aws.yaml

###########################
# Creating infrastructure #
###########################

cat cluster.yaml

kubectl apply --filename cluster.yaml

#######################
# Defining composites #
#######################

# It would be even better with Argo CD or Flux

cat definition.yaml

cat aws.yaml

kubectl describe \
    composition cluster-aws

kubectl explain \
    compositekubernetescluster \
    --recursive

#####################
# Resource statuses #
#####################

kubectl get compositekubernetesclusters

kubectl describe \
    compositekubernetescluster team-a

kubectl get clusters,nodegroup,iamroles,iamrolepolicyattachments,vpcs,securitygroups,subnets,internetgateways,routetables

kubectl get compositekubernetesclusters

# Wait until it's up-and-running

####################################
# Accessing the new infrastructure #
####################################

kubectl --namespace team-a \
    get secret cluster \
    --output jsonpath="{.data.kubeconfig}" \
    | base64 -d \
    | tee kubeconfig.yaml

export KUBECONFIG=$PWD/kubeconfig.yaml

kubectl get nodes

kubectl get namespaces

unset KUBECONFIG

###########################
# Updating infrastructure #
###########################

# Open cluster.yaml in an editor
# Uncomment `spec.parameters.minNodeCount`

kubectl apply --filename cluster.yaml

export KUBECONFIG=$PWD/kubeconfig.yaml

kubectl get nodes

#############################
# Destroying infrastructure #
#############################

unset KUBECONFIG

kubectl delete --filename cluster.yaml

kubectl get compositekubernetesclusters

kubectl get clusters

kubectl get clusters,nodegroup,iamroles,iamrolepolicyattachments,vpcs,securitygroups,subnets,internetgateways,routetables

# Wait until everything is removed

k3d cluster delete devops-toolkit