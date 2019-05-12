terraform {
  backend "azurerm" {
    storage_account_name = "tfsstatestorageaccount1"
    container_name       = "tfstate"
	key                  = "prod.terraform.tfstate"
    access_key                  = "/zrc1Zo4tldgDnT2nrJlro52d+9DMJurRrx/Np7nMzpzN4Qpcrn8ASWHgBdhzF0NBoyC35oeVYA59M9BKwXDNA=="
  }
}
#Provider Init
provider "azurerm" {
  version = ">= 1.0"
}
provider "local" {
  version = ">1.0"
}


#Variable declaration
variable "vm_name" {
    description = "Enter desired name of VM"
    type = "string"
}variable "vm_size" {
  description = "Enter the Size of VMs"
  default = "Standard_D2s_v3"
}

variable "count_of_VMs" {
  description = "Number of VMs you want to create as part of this deployment"
  #type = "string"
  default = 2
}
variable "OS_Image_Publisher" {
  description = "Give OS image with which you need to create virtual machines"
  type = "string"
  default = "Canonical"
}
variable "OS_Image_Offer" {
  description = "Provide the name of offer for the given publisher"
  type= "string"
  default = "UbuntuServer"
}
variable "OS_Image_Sku" {
  description = "Provide the version of sku. Ex:- 2019-Datacenter"
  type = "string"
  default = "16.04.0-LTS"
}
variable "chef_url" {
  description = "Provide Chef server URL"
  default = "https://demo-chef-automate.northcentralus.cloudapp.azure.com/organizations/default"
}


#Chef Provisioner Variables
variable "chef_provision" {
  description = "Configuration details for chef server"
  default = {
    server_url = "https://demo-chef-automate.northcentralus.cloudapp.azure.com/organizations/default"
    user_name = "bunty"
    user_key_path = "C:/starter-kit/chef-repo/.chef/bunty.pem"
    recreate_client = true
  }
}



#Data Reference of Virtual network/Subnet used to create VM 
data "azurerm_subnet" "subnet" {
  name = "app"
  virtual_network_name = "deops-vnet"
  resource_group_name = "vnet-rp-demo"
} 

#Data Reference of Storage Account used for boot diagnostics
data "azurerm_storage_account" "bootstorage" {
  name = "tfsstatestorageaccount1"
  resource_group_name = "storage-rp-demo"
}

#Data Reference of Key Vault
data "azurerm_key_vault" "keyvault" {
  name = "terraform-demo-kv"
  resource_group_name = "vault-rp-demo"
  
}

# Data Reference of Key Vault Secret severadminpwd
data "azurerm_key_vault_secret" "serveradminpwd" {
  name = "serveradminpwd"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"  
}


#Local file for chef validator file
resource "local_file" "validatorfile" {
  sensitive_content = "C:/starter-kit/chef-repo/.chef/default-validator.pem"
  filename = "C:/starter-kit/chef-repo/.chef/local_file.pem"  
}


#Create Resource Group
resource "azurerm_resource_group" "deployrg" {
    name = "app-terraform"
    location = "North Central US"
}

#Create Public IP
resource "azurerm_public_ip" "pip" {
  count = "${var.count_of_VMs}"
  name = "${var.vm_name}.${count.index}-pip"
  location = "${azurerm_resource_group.deployrg.location}"
  resource_group_name = "${azurerm_resource_group.deployrg.name}"
  allocation_method = "Static"
}

#Create NIC
resource "azurerm_network_interface" "nic" {
  count = "${var.count_of_VMs}"
  name = "${var.vm_name}.${count.index}-nic"
  location = "${azurerm_resource_group.deployrg.location}"
  resource_group_name = "${azurerm_resource_group.deployrg.name}"
  ip_configuration {
    name = "ipconfig"
    subnet_id = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${element(azurerm_public_ip.pip.*.id, count.index)}"
  }
}

#Create Availability Set
resource "azurerm_availability_set" "avset" {
  name = "${var.vm_name}-avset"
  location = "${azurerm_resource_group.deployrg.location}"
  resource_group_name = "${azurerm_resource_group.deployrg.name}"
  platform_fault_domain_count = 2
  platform_update_domain_count = 2
  managed = true
}

#Create Managed Disks
resource "azurerm_managed_disk" "mdisk" {
  count = "${var.count_of_VMs}"
  name = "${var.vm_name}-${count.index}-datadisk"
  location = "${azurerm_resource_group.deployrg.location}"
  resource_group_name = "${azurerm_resource_group.deployrg.name}"
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = "1023"  
}


#Create Windows Virtual Machine
resource "azurerm_virtual_machine" "Windows_VM" { 
  count = "${var.OS_Image_Publisher == "MicrosoftWindowsServer" ? var.count_of_VMs : 0 }"
  name = "${var.vm_name}-${count.index}"
  resource_group_name = "${azurerm_resource_group.deployrg.name}"
  availability_set_id = "${azurerm_availability_set.avset.id}"
  location = "${azurerm_resource_group.deployrg.location}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size = "${var.vm_size}"

  storage_image_reference{
    publisher = "${var.OS_Image_Publisher}"
    offer = "${var.OS_Image_Offer}"
    sku = "${var.OS_Image_Sku}"
    version = "latest"
  }
  storage_os_disk{
    name = "${var.vm_name}-${count.index}-osdisk"
    caching = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option = "FromImage"
  }

  storage_data_disk {
    name = "${element(azurerm_managed_disk.mdisk.*.name, count.index)}"
    managed_disk_id = "${element(azurerm_managed_disk.mdisk.*.id, count.index)}"
    create_option = "Attach"
    lun = 1
    disk_size_gb = "${element(azurerm_managed_disk.mdisk.*.disk_size_gb, count.index)}"
  }

  os_profile {
    computer_name = "${var.vm_name}-${count.index}"
    admin_username = "rxadmin"
    admin_password = "${data.azurerm_key_vault_secret.serveradminpwd.value}"
  }

  boot_diagnostics {
    enabled = true
    storage_uri = "${data.azurerm_storage_account.bootstorage.primary_blob_endpoint}"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }

  provisioner "local-exec" {
    command = "Select-AzureRmSubscription -Subscription 'fd7d53ef-e290-4ab1-937e-fec061c00132'"
    interpreter = ["powershell.exe", "-Command"]
  }
  provisioner "local-exec" {
    command = "Set-AzureRmVMChefExtension -ResourceGroupName ${azurerm_resource_group.deployrg.name} -VMName ${var.vm_name}-${count.index} -ValidationPem ${local_file.validatorfile.filename} -ChefServerUrl ${var.chef_url} -ValidationClientName 'default-validator' -RunList 'webserver' -Windows"
    #command = "powershell.exe az vm extension set --resource-group '${azurerm_resource_group.deployrg.name}' --vm-name '${var.vm_name}-${count.index}' --name 'ChefClient' --publisher 'Chef.Bootstrap.WindowsAzure' --version 1210.12 --protected-settings '${ "validation_key" : "{var.validatorfile}" }' --settings '{ "bootstrap_options": ${"chef_server_url": "${var.chef_url}" , "validation_client_name": "default-validator" }, "runlist": "webserver" }' "
    interpreter = ["powershell.exe", "-Command"]
  }

  tags {
    LOB = "DevOps"
    EnvTpye = "Non Production"
    Deployer = "bunty.ray@gmail.com"
    DeployDate = "${timestamp()}"
  }
}

#Custom Extension Script for Windows

    
#Chef Provisioner for Windows 


#Create Linux Virtual Machine
resource "azurerm_virtual_machine" "Linux_VM" { 
  count = "${var.OS_Image_Publisher != "MicrosoftWindowsServer" ? var.count_of_VMs : 0 }"
  name = "${var.vm_name}-${count.index}"
  resource_group_name = "${azurerm_resource_group.deployrg.name}"
  availability_set_id = "${azurerm_availability_set.avset.id}"
  location = "${azurerm_resource_group.deployrg.location}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size = "${var.vm_size}"

  storage_image_reference{
    publisher = "${var.OS_Image_Publisher}"
    offer = "${var.OS_Image_Offer}"
    sku = "${var.OS_Image_Sku}"
    version = "latest"
  }
  storage_os_disk{
    name = "${var.vm_name}-${count.index}-osdisk"
    caching = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option = "FromImage"
  }

  storage_data_disk {
    name = "${element(azurerm_managed_disk.mdisk.*.name, count.index)}"
    managed_disk_id = "${element(azurerm_managed_disk.mdisk.*.id, count.index)}"
    create_option = "Attach"
    lun = 1
    disk_size_gb = "${element(azurerm_managed_disk.mdisk.*.disk_size_gb, count.index)}"
  }

  os_profile {
    computer_name = "${var.vm_name}-${count.index}"
    admin_username = "rxadmin"
    admin_password = "${data.azurerm_key_vault_secret.serveradminpwd.value}"
  }

  boot_diagnostics {
    enabled = true
    storage_uri = "${data.azurerm_storage_account.bootstorage.primary_blob_endpoint}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "local-exec" {
    working_dir = "C:/starter-kit/chef-repo/.chef/"
    command = "echo ${data.azurerm_key_vault_secret.serveradminpwd.value} | knife bootstrap ${element(azurerm_public_ip.pip.*.ip_address, count.index)} -N ${var.vm_name}-${count.index} -x rxadmin -P ${data.azurerm_key_vault_secret.serveradminpwd.value} --sudo --run-list 'baseline-infra-install' "
  }

  tags {
    LOB = "DevOps"
    EnvTpye = "Non Production"
    Deployer = "bunty.ray@gmail.com"
    DeployDate = "${timestamp()}"
  }
}
