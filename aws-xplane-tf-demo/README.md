# README
The **aws-xplane-tf-demo** directory contains projects to testing and
demonstrating the Nethopper's PaaS' ability to create infrastructure using
Crossplane, Crossplane's Terraform (TF) provider, and ArgoCD.

## Project Directory Structure
A project is considered a resource created by Crossplane's TF provider and
managed in a declaritive manner by ArgoCD. Each project must have a directory
under both the **modules** and **workspaces** directories. For consistency and
usabilty the sub-directories should have the same name
(e.g. *eks-aws* under modules and workspaces).

The **modules** directory contains project scoped TF modules required to build
the resource. For demo purposes this directory is considered existing TF a 
customer would bring.

The **workspaces** directory contain project scoped TF workspaces required for
a resource to be created and managed by Crossplane. These workspaces are used by
Crossplane to instantiate infra in the corresponding modules directory.


## Projects
Each project is detailed in the following sub-sections.

### eks-aws
This project provides three workspaces, *remote-eks-dev/remote-eks-prod/remote-eks-qa*,
which create three EKS clusters in AWS. They are intended to be edge clusters
(no EIP) in an application network. Consider dev/prod/qa as EKS cluster
instantiations of the same TF modules directory.

Each workspace resides in its own sub-directory under ./workspace/eks-aws.

The TF modules required to create them are under ./modules/eks-aws.

### vcp-aws
This project provides the simplest way to test Crossplane TF provider. It
creates a single VPC in EKS.

Each workspace resides in its own sub-directory under ./workspace/eks-aws. 

The TF modules required to create them are under ./modules/eks-aws.
