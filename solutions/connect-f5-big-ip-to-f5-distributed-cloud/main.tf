################################################################################
# F5 Distributed Cloud
################################################################################

resource "volterra_namespace" "namespace" {
  name = var.volterra_namespace_name
}

resource "volterra_token" "token" {
  name      = "this-does-not-matter"
  namespace = "system"
}

resource "volterra_voltstack_site" "volterra_site" {
  name      = var.volterra_site_name
  namespace = "system"

  volterra_certified_hw = var.volterra_certified_hardware
  master_nodes = [
    var.volterra_master_hostname
  ]
}

resource "time_sleep" "registration_wait" {
  depends_on = [
    vsphere_virtual_machine.f5xc_node
  ]

  triggers = {
    vm_id = vsphere_virtual_machine.f5xc_node.id
  }

  create_duration = "600s"
}
resource "volterra_registration_approval" "approval" {
  depends_on = [
    volterra_voltstack_site.volterra_site,
    time_sleep.registration_wait
  ]

  cluster_name = var.volterra_site_name
  cluster_size = 1
  hostname     = var.volterra_master_hostname
}

resource "volterra_origin_pool" "pool" {
  depends_on = [
    volterra_namespace.namespace,
    volterra_registration_approval.approval
  ]

  name                   = format("%s-pool", var.volterra_site_name)
  namespace              = var.volterra_namespace_name
  loadbalancer_algorithm = "LB_OVERRIDE"
  endpoint_selection     = "LOCAL_PREFERRED"

  origin_servers {
    private_ip {
      ip = "192.0.2.1"
      site_locator {
        site {
          name = var.volterra_site_name
        }
      }
      outside_network = true
    }
  }

  port = 80
}

################################################################################
# VMware VSphere
################################################################################

data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "outside" {
  name          = var.vsphere_network_outside
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "inside" {
  name          = var.vsphere_network_inside
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "f5xc_node" {
  name = "f5xc-node"

  datacenter_id    = data.vsphere_datacenter.datacenter.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id

  num_cpus = 4
  memory   = 16384

  network_interface {
    network_id   = data.vsphere_network.outside.id
    adapter_type = "vmxnet3"
  }
  network_interface {
    network_id   = data.vsphere_network.inside.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 120
    eagerly_scrub    = false
    thin_provisioned = false
    io_share_count   = 1000
  }

  ovf_deploy {
    remote_ovf_url    = "https://downloads.volterra.io/releases/images/2022-09-15/centos-7.2009.27-202209150812.ova"
    disk_provisioning = "thick"
    ovf_network_map = {
      "OUTSIDE" = data.vsphere_network.outside.id
      "REGULAR" = data.vsphere_network.inside.id
    }
  }

  vapp {
    properties = {
      "guestinfo.hostname"              = var.volterra_master_hostname
      "guestinfo.ves.adminpassword"     = var.volterra_node_password
      "guestinfo.ves.certifiedhardware" = var.volterra_certified_hardware
      "guestinfo.ves.clustername"       = var.volterra_site_name
      "guestinfo.ves.latitude"          = "47.606209"   # Seattle
      "guestinfo.ves.longitude"         = "-122.332069" # Seattle
      "guestinfo.ves.token"             = volterra_token.token.id
    }
  }
}
