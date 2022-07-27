variable "location" {
    type          = string
    default       = "westeurope"
    description   = "Location of the resource group."
}

variable resource_group_name {
    type    = string
    default = "azure-k8stest"
}

variable "vnet" {
  type = object({
    name           = string
    address_space  = string
  })
}

variable "subnet_list" {
  description = "List of objects that will create subnets"
  type = list(object({
    name                       = string
    address_prefixes           = list(string)
  }))
  default = []
}

variable cluster_name {
    type    = string
    default = "k8stest"
}

variable private_cluster_enabled {
    type    = bool
    default = false
}

variable kubernetes_version {
    type    = string
}

variable "node_count" {
    type    = number
    default = 1
}

variable "node_avzones" {
  description = "Availability Zones to deploy the nodes across. network_outbound_type must be set to loadBalancer if using zones."
  type        = list(string)
  default     = []
}

variable network_plugin {
    type    = string
    default = "kubenet"
}

variable network_policy {
    type    = string
    default = "calico"
}

variable "default_node_pool" {
  type = object({
    name                  = string
    orchestrator_version  = string
    vm_size               = string
    os_disk_size_gb       = number
    os_disk_type          = string
    node_count            = number
    enable_auto_scaling   = bool
    min_count             = number
    max_count             = number
    max_pods              = number
    enable_public_ip      = bool
    ultra_ssd_enabled     = bool
    labels                = map(string)
    taints                = list(string)
  })
}

variable "custom_nodepools" {
  type = list(object({
    name                  = string
    orchestrator_version  = string
    vm_size               = string
    os_disk_size_gb       = number
    os_disk_type          = string
    node_count            = number
    enable_auto_scaling   = bool
    min_count             = number
    max_count             = number
    max_pods              = number
    enable_public_ip      = bool
    ultra_ssd_enabled     = bool
    labels                = map(string)
    taints                = list(string)
  }))
  default = []
}