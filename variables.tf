variable "provider_name" {
    type = "string"
    default = ""
}


#VMware Variables################

variable vsphere_user{}
variable vsphere_password{}
variable vsphere_server {}

variable vm_instance_count {
    type = number
    default = 1
}



variable "appname" {
    
    default = ""
}

variable "instance_count" {
    default = "2"
}


variable "os_user" {
  default = "root"
}

variable "services" {
}

variable "template" {
}


