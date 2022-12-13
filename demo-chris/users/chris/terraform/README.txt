### To add infra using Crossplane Terraform proivder to 3.7.1, do the following.

Step1: apply crossplane terraform provider
k apply -f provider-tf.txt
#NOTE: Wait for provider to be ready.  k get provider

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
k apply -f providerconfig.txt

Step4:


