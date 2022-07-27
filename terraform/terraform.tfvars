location                        = "westeurope"
resource_group_name             = "playground-aks-fluentbit-falco"

vnet = {
    name                = "vnet-infra"
    address_space       = "10.100.0.0/16"
}

subnet_list = [{
    name                       = "aks-subnet"
    address_prefixes           = [ "10.100.1.0/24" ]
}]

cluster_name                    = "aks-fluentbit-falco"
private_cluster_enabled         = false
kubernetes_version              = "1.21.9"
node_avzones                    = ["1", "2", "3"]
network_plugin                  = "kubenet"
network_policy                  = "calico"

default_node_pool = {
    name                  = "default"
    orchestrator_version  = "1.21.9"
    vm_size               = "Standard_B4ms"
    os_disk_size_gb       = 100
    os_disk_type          = "Managed"
    node_count            = 1
    enable_auto_scaling   = true
    min_count             = 1
    max_count             = 2
    max_pods              = null
    enable_public_ip      = false
    ultra_ssd_enabled     = false
    labels = {}
    taints = []
}

custom_nodepools = []