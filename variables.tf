variable "provider_name" {
    default = ""
}


#VMware Variables################

variable vsphere_user{}
variable vsphere_password{}
variable vsphere_server {}



variable "appname" {
    
    default = ""
}

variable "instance_count" {
    default = "3"
}


variable "os_user" {
  default = "root"
}

variable "services" {
}

variable "template" {
}


