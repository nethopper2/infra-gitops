### To add infra using Crossplane Terraform proivder to 3.7.1, do the following.
cd demo-chris/users/chris/terraform/

Step1: apply crossplane terraform provider
k apply -f provider-tf.yaml
k get provider
#NOTE: Wait for terraform-provider to be HEALTHY=True.

Step2: Apply the needed secrets
echo '
---
apiVersion: v1
kind: Secret
metadata:
  name: aws-creds
  namespace: nethopper
type: Opaque
stringData:
  credentials: |
    [default]
    aws_access_key_id = 'your access key id'
    aws_secret_access_key = 'your access key'
---
apiVersion: v1
kind: Secret
metadata:
  name: git-credentials
  namespace: nethopper
type: Opaque
stringData:
  creds: |
    https://username:pat@github.com
' > secrets.yaml

k apply -f secrets.yaml -n nethopper &&
rm secrets.yaml

#NOTE: never save creds to git

Step3: apply crossplane terraform provider config
k apply -f providerconfig.yaml
k get providerconfig.
NOTE: no need to wait for anything

Step4: apply terraform workspace (remote type)
k apply -f workspace-remote.yaml 
k get workspace
NOTE: Wait for workspace to be synced and ready

Step5: Check AWS console us-west-2 for a new vpc

Step6: Modify TF files in terraform/vpc-aws and commit/push.  Then wait for AWS console to update

Step7: If you just created a kubernetes cluster, you can access it with (note, this requires the AWS cli):
aws eks --region <region> update-kubeconfig --name <cluster-name>
kubectl config get-contexts


Step8: Delete terraform stuff defined in the workspace directory and the namespaces it was created in
k delete -f workspace-remote.yaml
k delete ns test123
NOTE: This command will take some time, because it is waiting for AWS to confirm vpc delete, on a crossplane sync cycle.  Check your AWS console.

Step9: delete provider, providerconfig, secrets and namespaces
k delete providerconfig tf-pc
k delete provider terraform-provider
k delete secrets aws-creds git-credentials -n nethopper
