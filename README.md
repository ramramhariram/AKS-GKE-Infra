# AKS-GKE-Infra
TF code that deploys network infrastructure for an AKS as well as a GKE Cluster

![Total Build](/images/AKS+GKE+Infra.png)

Required:  
Azure CLI Access to correct subscription.  
Azure SP for deploying AKS Cluster and creating TFvars files using same - Example here - https://learn.hashicorp.com/tutorials/consul/kubernetes-aks-azure#create-an-aks-cluster-with-terraform\.  
Gcloud CLI access and credentials. 
Gcloud Project user needs to have Kubernetes Engine Admin role to create GKE clusters.  

