# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg2" {
  name     = "rg2"
  location = "West US 2"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet2"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  address_space       = ["10.67.0.0/16"]
}

output subnet_id {
    value = azurerm_subnet.hrssubnet.id
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.67.1.0/24"]
}


variable "prefix" {
  default = "hrs1"
}

variable "appId" {
}

variable "password" {
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.hrsrg2.location
  resource_group_name = azurerm_resource_group.hrsrg2.name
  dns_prefix          = "${var.prefix}-k8s"

 default_node_pool {
    name            = "default"
    node_count      = 3 
    vm_size         = "Standard_D8_v3"
    vnet_subnet_id  = azurerm_subnet.hrssubnet.id
    #os_type         = "Linux" implicit now.
    os_disk_size_gb = 30
 } 
#linux_os_config {}
  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo"
  }

  provisioner "local-exec" {
    # Load credentials to local environment so subsequent kubectl commands can be run
    command = <<EOS
      az aks get-credentials --resource-group ${azurerm_resource_group.hrsrg2.name} --name ${self.name} --overwrite-existing;

EOS

  }
}

#######GKE########


variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 3
  description = "number of gke nodes"
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.project_id}-np"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n2-standard-8"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

