# To create GKE cluster using Nethopper KAOPS, do the following:

1. Clone this repo

2. Update workspace.yaml with your desired variables
- make sure that git::https://github.com/nethopper2/infra-gitops.git//demo/users/chris/terraform/gke-gcp is updated for your new git location where your .tf files are located

# Use Nethopper KAOPS:
3a. Create a Network (or use an existing one)
3b. Install Hub (admin) K8s cluster at the place of your choosing (laptop, server, cloud).

4. On "IaC" Page, Actions -> "Create a Provider"
- Provider type (e.g. Cloud provider) = Terraform
- Configuration Name = gcpconf
- Add Credentials
  - Custom
  - Provider Name = gcp (or any name)
  - Cred Filename = gcp-creds.ini
  - Cred File Contents = (paste your json here, like the contents of ~/.config/gcloud/application_default_credentials.json)

5. On "IaC" Page, Actions -> "Create Infrastructure"
- Cloud Provider = gcpconf
- Repository configuration
  - Point to a repo that contains your workspace.yaml.

6. To Verify success/failure
- On IaC page, the conditions of the infrastructure you just created should be READY=True when successful.

7. To access the GKE cluster using kubectl
- Add the context to your terminal with the command, 'gcloud container clusters get-credentials test-dd662-gke --region us-central1'
- replace test-dd662-gke with your cluster name
- replace us-central1 with your region name
- Now, you can install your Nethopper agent to deploy apps to this cluster


For more info - see docs at nethopper.io.
