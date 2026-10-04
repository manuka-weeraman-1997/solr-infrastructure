# Example: a 3-node ZooKeeper ensemble as fixed (non-scale-set) VMs.
#
# Each node needs a stable identity (its position in the ensemble, e.g.
# zk1/zk2/zk3) for quorum - a VMSS that can replace any instance with a
# fresh one at any time is the wrong tool here.

resource "azurerm_network_interface" "zk" {
  for_each            = toset(var.node_names)
  name                = "nic-${each.key}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.node_ips[each.key]
  }
}

resource "azurerm_linux_virtual_machine" "zk" {
  for_each            = toset(var.node_names)
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [azurerm_network_interface.zk[each.key].id]

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

  # myid and the ensemble's server list differ per node - each gets its own
  # rendered config rather than one shared custom_data script.
  custom_data = base64encode(templatefile("${path.module}/cloud-init.sh.tpl", {
    myid         = index(var.node_names, each.key) + 1
    server_lines = local.server_lines
  }))
}
