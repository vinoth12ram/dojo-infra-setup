terraform {
 required_providers {
   azurerm = {
     source = "hashicorp/azurerm"
   }
 }
 backend "azurerm" {
      resource_group_name  = "DOJO"
      storage_account_name = "dojostorage1"
      container_name       = "dojo"
      key                  = "terraform.tfstate"    
  }
}



provider "azurerm" {
  features {}
}

locals {
  env_type = "${terraform.workspace}"
}

data "azurerm_resource_group" "this" {
  name = "DOJO"
}


module "networking" {
  source          = "./modules/networking"
  location        = var.location
  resource_group  = data.azurerm_resource_group.this.id
  vnetcidr        = var.vnetcidr
  websubnetcidr   = var.websubnetcidr
  appsubnetcidr   = var.appsubnetcidr
  dbsubnetcidr    = var.dbsubnetcidr
  clientcidr      = var.clientcidr
  vnet_name       = "${local.env_type}-${var.vnet_name}"
  web_subnet_name = "${local.env_type}-${var.web_subnet_name}"
  app_subnet_name = "${local.env_type}-${var.app_subnet_name}"
  db_subnet_name  = "${local.env_type}-${var.db_subnet_name}"
  vpn_gw          = "${local.env_type}-${var.vpn_gw}"
  vpn_gw_pip      = "${local.env_type}-${var.vpn_gw_pip}"
}

module "securitygroup" {
  source         = "./modules/securitygroup"
  location       = var.location
  resource_group = data.azurerm_resource_group.this.id
  web_subnet_id  = module.networking.websubnet_id
  app_subnet_id  = module.networking.appsubnet_id
  db_subnet_id   = module.networking.dbsubnet_id
}

module "compute" {
  source                = "./modules/compute"
  location              = var.location
  resource_group        = data.azurerm_resource_group.this.id
  web_availibility_set  = "${local.env_type}-${var.web_availibility_set}"
  web_network_interface = "${local.env_type}-${var.web_network_interface}"
  web_win_vm            = "${local.env_type}-${var.web_win_vm}"
  app_availibility_set  = "${local.env_type}-${var.app_availibility_set}"
  app_network_interface = "${local.env_type}-${var.app_network_interface}"
  app_win_vm            = "${local.env_type}-${var.app_win_vm}"
  web_subnet_id         = module.networking.websubnet_id
  app_subnet_id         = module.networking.appsubnet_id
  web_host_name         = "${local.env_type}-${var.web_host_name}"
  web_username          = "${local.env_type}-${var.web_username}"
  web_os_password       = var.web_os_password
  app_host_name         = "${local.env_type}-${var.app_host_name}"
  app_username          = "${local.env_type}-${var.app_username}"
  app_os_password       = var.app_os_password
}

module "database" {
  source                    = "./modules/database"
  location                  = var.location
  resource_group            = data.azurerm_resource_group.this.id
  db_name                   = "${local.env_type}-${var.db_name}"
  primary_database          = "${local.env_type}-${var.primary_database}"
  primary_database_version  = var.primary_database_version
  primary_database_admin    = var.primary_database_admin
  primary_database_password = var.primary_database_password
}

module "loadbalancer" {
  source         = "./modules/loadbalancer"
  location       = var.location
  resource_group = data.azurerm_resource_group.this.id
  lb_name        = "${local.env_type}-${var.lb_name}"
  lb_pip_name    = "${local.env_type}-${var.lb_pip_name}"

}
