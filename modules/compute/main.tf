resource "azurerm_availability_set" "web_availabilty_set" {
  name                = var.web_availibility_set
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_network_interface" "web-net-interface" {
    name = var.web_network_interface
    resource_group_name = var.resource_group
    location = var.location

    ip_configuration{
        name = "web-webserver"
        subnet_id = var.web_subnet_id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "web-vm" {
  name = var.web_win_vm
  location = var.location
  resource_group_name = var.resource_group
  network_interface_ids = [ azurerm_network_interface.web-net-interface.id ]
  admin_username = var.web_username
  admin_password = var.web_os_password
  availability_set_id = azurerm_availability_set.web_availabilty_set.id
  size = "Standard_D2s_v3"
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
  
  
  resource "azurerm_availability_set" "app_availabilty_set" {
  name                = var.app_availibility_set
  location            = var.location
  resource_group_name = var.resource_group
 }

resource "azurerm_network_interface" "app-net-interface" {
    name = var.app_network_interface
    resource_group_name = var.resource_group
    location = var.location

    ip_configuration{
        name = "app-webserver"
        subnet_id = var.app_subnet_id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "app-vm" {
  name = var.app_win_vm
  location = var.location
  resource_group_name = var.resource_group
  admin_username = var.app_username
  admin_password = var.app_os_password
  network_interface_ids = [ azurerm_network_interface.app-net-interface.id ]
  availability_set_id = azurerm_availability_set.web_availabilty_set.id
  size = "Standard_D2s_v3"

 source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }  

}

