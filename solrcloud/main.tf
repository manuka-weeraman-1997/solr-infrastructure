# Example: SolrCloud node fleet as a fixed-size Virtual Machine Scale Set.
#
# Deliberately NOT autoscaled on CPU like a typical stateless VMSS -
# SolrCloud shards/replicas are explicitly placed across nodes via the
# Collections API, so a node appearing or disappearing on its own (rather
# than as a planned capacity change) risks under-replicated shards rather
# than just "fewer instances handling the same stateless work".

resource "azurerm_linux_virtual_machine_scale_set" "solr" {
  name                = "solrcloud-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_size
  instances           = var.node_count
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching               = "ReadWrite"
  }

  # Solr's own index data lives on a separate managed data disk, not the OS
  # disk - so re-imaging/upgrading a node's OS disk never touches index data.
  data_disk {
    lun                  = 0
    caching              = "ReadWrite"
    create_option        = "Empty"
    disk_size_gb         = var.data_disk_size_gb
    storage_account_type = "Premium_LRS"
  }

  network_interface {
    name    = "solr-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      subnet_id = var.subnet_id
    }
  }

  # Upgrades go one node at a time (see README) - the next node only starts
  # upgrading once the previous one is healthy again.
  upgrade_mode = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 34
    max_unhealthy_instance_percent          = 34
    max_unhealthy_upgraded_instance_percent = 34
    pause_time_between_batches              = "PT1M"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.sh.tpl", {
    zk_connect_string = var.zk_connect_string
  }))
}
