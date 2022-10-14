# AKS-GKE-Infra
TF code that deploys network infrastructure for an AKS as well as a GKE Cluster

![Total Build](/images/AKS+GKE+Infra.png)

Required:  
Azure CLI Access to correct subscription.  
Azure SP for deploying AKS Cluster and creating TFvars files using same - Example here - https://learn.hashicorp.com/tutorials/consul/kubernetes-aks-azure#create-an-aks-cluster-with-terraform\.  
(This is the only variables that will need to be passed for the AKS module) 

Gcloud CLI access and credentials.   
Gcloud Project user needs to have Kubernetes Engine Admin role to create GKE clusters.  
Once known, add the GCP project id and region to the terraform.tfvars file

Optional: 
May want to change the name of RG, Subnets etc. to what is more relevant to your environment
