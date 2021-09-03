# Terraform - EKS - Helm

## Project Objectives

1. TLS Offloading and Load Balancer.

LoadBalancer type service creates a L4 load balancer. L4 load balancers are aware about source IP:port and destination IP:port, but they are not aware about anything on the application layer.

HTTP/HTTPS load balancers are on L7, therefor they are application aware.

So, basically you it is not possible to get  a HTTPS load balancer from a LoadBalancer type service. The achieve it, a Ingress controller is needed.

Nginx was the choice for this project. Since it is one of the most used by the community, and has a great support.

To manage certificates, Cert-Manager was the choice for this project. It is the most popular solution used in Kubernetes and has a great support from the community.

2. Automation

The whole process is fully automated. There are two pipelines. One is responsible for creating the whole infra on AWS, after this pipeline finishes it is gonna trigger
a second pipeline which is responsible for configuring the following add-ons:

- Metrics Server
- Nginx Ingress Controller
- Cert-Manager
- Cert-Manager Issuers(Prod/Staging)

## Solution Explanation

Cert-manager is a native Kubernetes certificate management controller. It can help with issuing certificates from a variety of sources, such as Let’s Encrypt, HashiCorp Vault, Venafi, a simple signing keypair, or self signed.

It will ensure certificates are valid and up to date, and attempt to renew certificates at a configured time before expiry.

The sub-component ingress-shim watches Ingress resources across the cluster. If it observes an Ingress with a supported annotation, it will ensure a Certificate resource with the name provided in the tls.secretName field and configured as described on the Ingress exists.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    # add an annotation indicating the issuer to use.
    cert-manager.io/cluster-issuer: nameOfClusterIssuer
  name: myIngress
  namespace: myIngress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: myservice
            port:
              number: 80
  tls: # < placing a host in the TLS config will determine what ends up in the cert's subjectAltNames
  - hosts:
    - example.com
    secretName: myingress-cert # < cert-manager will store the created certificate in this secret.
```

## Technologies Used

1. Terraform
    - Used to build and manage infrastructure as code
2. Amazon EKS (Elastic Kubernetes Service)
    - Cloud-based container management service that natively integrates with Kubernetes to deploy applications.
3. Helm
    - Package manager for Kubernetes that allows developers and operators to more easily package, configure, and deploy applications and services into Kubernetes clusters.

4. Nginx Ingress-controller
   - ingress-nginx is an Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.

5. Cert-Manager
   - cert-manager is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources.

## List of folders/files and their descriptions

1. [helpers](helpers) Contains scripts used by GitHub Actions.
2. [cm-issuers](cm-issuers) Contains Cert-Manager Prod and Staging issuers.
3. [main.tf](main.tf) File responsible for the modules composition. It is responsible for "calling" external Terraform modules to create VPC, EKS-MASTER and EKS-NODES
4. [backend.tf](variables.tf) File responsible for the backend configuration to connect to terraform cloud, where the state file is being kept.
   
## GitHub Actions Workflows

1. [terraform.yaml](.github/workflows/terraform.yaml) Workflow responsible for creating AWS infra.
2. [configure-eks.yaml](.github/workflows/configure-eks.yaml) Workflow responsible for installing EKS add-ons.

## Configuring GitHub Actions Workflows

The workflow needs three secrets in order to work: 

- TF_API_TOKEN: Token used to connect to Terraform Cloud
- AWS_ACCESS_KEY_ID: Access key used by AWS CLI
- AWS_SECRET_ACCESS_KEY: Secret key used by AWS CLI
