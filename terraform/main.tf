resource "azurerm_resource_group" "rg" {
  name      = var.resource_group_name
  location  = var.location
}

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "logs-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  retention_in_days   = 30
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [ var.vnet.address_space ]
}

resource "azurerm_subnet" "subnets" {
  count = length(var.subnet_list)

  name                 = element(var.subnet_list.*.name, count.index)
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = element(var.subnet_list.*.address_prefixes, count.index)
}

resource "azurerm_user_assigned_identity" "umi" {
  name                = "umi"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                    = var.cluster_name
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  dns_prefix              = var.cluster_name
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name                  = var.default_node_pool.name
    orchestrator_version  = var.default_node_pool.orchestrator_version
    vm_size               = var.default_node_pool.vm_size
    
    enable_node_public_ip = var.default_node_pool.enable_public_ip
    os_disk_size_gb       = var.default_node_pool.os_disk_size_gb
    os_disk_type          = var.default_node_pool.os_disk_type
    vnet_subnet_id        = azurerm_subnet.subnets[0].id
    node_count            = var.default_node_pool.node_count
    enable_auto_scaling   = var.default_node_pool.enable_auto_scaling
    min_count             = var.default_node_pool.enable_auto_scaling == true ? var.default_node_pool.min_count : null
    max_count             = var.default_node_pool.enable_auto_scaling == true ? var.default_node_pool.max_count : null
    max_pods              = var.default_node_pool.max_pods
    ultra_ssd_enabled     = var.default_node_pool.ultra_ssd_enabled
    node_labels           = var.default_node_pool.labels
    node_taints           = var.default_node_pool.taints
    zones                 = var.node_avzones
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.umi.id]
  }

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy == "none" ? null : var.network_policy
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "custom_nodepools" {
  count                 = length(var.custom_nodepools)
  name                  = element(var.custom_nodepools.*.name, count.index)
  orchestrator_version  = element(var.custom_nodepools.*.orchestrator_version, count.index)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vnet_subnet_id        = azurerm_subnet.subnets[0].id
  vm_size               = element(var.custom_nodepools.*.vm_size, count.index)
  os_disk_size_gb       = element(var.custom_nodepools.*.os_disk_size_gb, count.index)
  os_disk_type          = element(var.custom_nodepools.*.os_disk_type, count.index)
  enable_auto_scaling   = element(var.custom_nodepools.*.enable_auto_scaling, count.index)
  node_count            = element(var.custom_nodepools.*.node_count, count.index)
  min_count             = element(var.custom_nodepools.*.min_count, count.index)
  max_count             = element(var.custom_nodepools.*.max_count, count.index)
  max_pods              = element(var.custom_nodepools.*.max_pods, count.index)
  enable_node_public_ip = element(var.custom_nodepools.*.enable_public_ip, count.index)
  ultra_ssd_enabled     = element(var.custom_nodepools.*.ultra_ssd_enabled, count.index)
  node_labels           = element(var.custom_nodepools.*.labels, count.index)
  node_taints           = element(var.custom_nodepools.*.taints, count.index)
  zones                 = var.node_avzones

  lifecycle {
    ignore_changes = [
      node_count,
      os_disk_size_gb,
      os_disk_type
    ]
  }

  depends_on = [azurerm_kubernetes_cluster.k8s]
}