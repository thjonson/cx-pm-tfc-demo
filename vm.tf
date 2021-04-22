
locals {
  # A list of objects with one object per instance...
  instances = flatten([
    for service_name_details in var.services : [
      for index in range(service_name_details.instance_count) : {
        # availability_zone = image.availability_zone
        # flavor            = image.flavor
        instance_index    = index
        dc_name           = service_name_details.dc_name
        cluster_name      = service_name_details.cluster_name
        datastore_name    = service_name_details.datastore_name
        pool              = service_name_details.pool
        #template          = service_name_details.template
        network           = service_name_details.network
        service_name      = service_name_details.service_name
        num_cpus          = service_name_details.num_cpus
        memory            = service_name_details.memory
        # security_group_ids = split(",", service_name_details.securitygroupsctrl)
        install_commands = split(";", service_name_details.install_commands)

      }
      
    ]
  ])
}



  
 data "vsphere_datacenter" "dc" {
      # name = "HX30-Lab"
      for_each = {
        # Generate a unique string identifier for each instance
        for inst in local.instances : format("%s-%02d", inst.service_name, inst.instance_index + 1) => inst
      }
        name = each.value.dc_name
  }

   data "vsphere_compute_cluster" "cluster" {
    # name          = "hx3.0-cluster-1"
      for_each = {
        # Generate a unique string identifier for each instance
        for inst in local.instances : format("%s-%02d", inst.service_name, inst.instance_index + 1) => inst
      }
      name = each.value.cluster_name
    datacenter_id = data.vsphere_datacenter.dc[each.key].id


  }

   data "vsphere_datastore" "datastore" {
     for_each = {
        # Generate a unique string identifier for each instance
        for inst in local.instances : format("%s-%02d", inst.service_name, inst.instance_index + 1) => inst
      }
    # name          = "HX1-TRNG"
     name = each.value.datastore_name
    datacenter_id = data.vsphere_datacenter.dc[each.key].id
  }

   data "vsphere_resource_pool" "pool" {

     for_each = {
        # Generate a unique string identifier for each instance
        for inst in local.instances : format("%s-%02d", inst.service_name, inst.instance_index + 1) => inst
      }
    # name          = "terraform-test"
    name = each.value.pool
    datacenter_id = data.vsphere_datacenter.dc[each.key].id
  }

   data "vsphere_network" "network" {
    # name          = "vm-network-140"
    for_each = {
        # Generate a unique string identifier for each instance
        for inst in local.instances : format("%s-%02d", inst.service_name, inst.instance_index + 1) => inst
      }
    name          = each.value.network
    datacenter_id = data.vsphere_datacenter.dc[each.key].id
  }

   data "vsphere_virtual_machine" "template" {
    # name          = "CentOS7.5-Template"
    for_each = {
        # Generate a unique string identifier for each instance
        for inst in local.instances : format("%s-%02d", inst.service_name, inst.instance_index + 1) => inst
      }
    name = var.template
    datacenter_id = data.vsphere_datacenter.dc[each.key].id
  }



resource "random_integer" "priority" {
  min     = 50000
  max     = 80000
  
  
}

resource "vsphere_virtual_machine" "vm" {


  for_each = {
    # Generate a unique string identifier for each instance
    for inst in local.instances : format("%s-%02d", inst.service_name, inst.instance_index + 1) => inst
  }

 


  name             = "mfs_instance_${each.key}_${random_integer.priority.result}"
  resource_pool_id = data.vsphere_resource_pool.pool[each.key].id
  datastore_id     = data.vsphere_datastore.datastore[each.key].id

  num_cpus = each.value.num_cpus
  memory   = each.value.memory
  guest_id = data.vsphere_virtual_machine.template[each.key].guest_id
  scsi_type = data.vsphere_virtual_machine.template[each.key].scsi_type
  network_interface {
    network_id = data.vsphere_network.network[each.key].id
  }

  # disk {
  #   label = "disk0"
  #   size  = 20
  # }


  disk {
      label            = "disk0"
      size             = "${data.vsphere_virtual_machine.template[each.key].disks.0.size}"
      eagerly_scrub    = "${data.vsphere_virtual_machine.template[each.key].disks.0.eagerly_scrub}"
      thin_provisioned = "${data.vsphere_virtual_machine.template[each.key].disks.0.thin_provisioned}"
    }
    
  clone {
      template_uuid = "${data.vsphere_virtual_machine.template[each.key].id}"

      # customize {
      #   linux_options {
      #     host_name = "terraform-test"
      #     domain    = "test.internal"
      #   }

      #   # network_interface {
      #   #   ipv4_address = "10.0.0.10"
      #   #   ipv4_netmask = 24
      #   # }

      #   # ipv4_gateway = "10.0.0.1"
      # }
    }

#     connection {
#     type = "ssh"
#     user = var.os_user
#     # private_key = "file("${../../keys}/var.privatekey_filename")"
#     # private_key = file("../../keys/${var.privatekey_filename}")
#     password = "C!sc0123"
#     host = self.default_ip_address
#     agent = false

#   }

  
#   # provisioners - File 
#     #  variable src {
#     #    default = "../../apps/ansible/var.appname"
#     #  }
#   provisioner "file" {

#     source      = "../../apps/ansible/${lower(each.value.service_name)}"
#     destination = "/tmp/"

#  }


  


# provisioner "remote-exec" {
#     inline = each.value.install_commands
    
#   }
   

   



}
