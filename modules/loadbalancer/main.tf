resource "azurerm_public_ip" "this" {
  name                = var.lb_pip_name
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
}

resource "azurerm_lb" "this" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.this.id
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  name                = "BackEndAddressPool"
  loadbalancer_id     = azurerm_lb.this.id
}

resource "azurerm_lb_probe" "this" {
  name                = "probe"
  loadbalancer_id     = azurerm_lb.this.id
  port                = 3389
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "example" {
  name                           = "TCP"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.this.id
}