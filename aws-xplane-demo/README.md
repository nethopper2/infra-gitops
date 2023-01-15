# README
The **aws-xplane-demo** directory contains projects to testing and demonstrating
the Nethopper's PaaS' ability to create infrastructure using Crossplane and
ArgoCD.

## Crossplane Compositions, XRDs, and XRs
Resources created by Crossplane require a *Composition*, *Composite Resource (XR)*,
and a *Composite Resource Definition (XRD)*. 

The following table defines each of these terms and provides notes on their
Terraform (TF) and Helm comparison/equivalent (if applicable). 

| TERM | DEFINTION | TF/Helm Comparisons | EXAMPLE |
| :--- | :--- | :--- | :--- |
| Composition | Custom API that tells Crossplane how to compose resources | TF module/Helm template | ./xrd/eks-aws/aws.yaml |
| XR | Composite Resource; Input to Composition | TF *tfvars*/Helm *values.yaml* file |./xr/eks-aws/dev/eks-cluster-dev.yaml |
| XRD | Composite Resource Defintion; Schema for an XR | TF variable block |./xrd/eks-aws/definition.yaml |

## Project Directory Structure
A project is considered a resource created by Crossplane and managed in a 
declaritive manner by ArgoCD. Each project must have a directory under both the
**xr** and **xrd** directories. For consistency and usabilty the sub-directories
should have the same name (e.g. *eks-aws* under xr and xrd).

The **xr** directory contains the XR for the resource to be created and managed
by Crossplane.

The **xrd** directory contains the Composition and XRD for the XR.

## Projects
Each project is detailed in the following sub-sections.

### eks-aws
This project provides three XRs, *dev/prod/qa*, which create three EKS clusters
in AWS. They are intended to be edge clusters (no EIP) in an application
network. Consider dev/prod/qa as EKS cluster instantiations of the same
Composition/XRD.

Each XR resides in its own sub-directory under ./xr/eks-aws. Their Composition
and XRD reside under ./xrd/eks-aws.