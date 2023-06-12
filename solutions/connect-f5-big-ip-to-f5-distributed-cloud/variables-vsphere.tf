variable "vsphere_user" {
  nullable    = true
  type        = string
  description = "This is the username for vSphere API operations. Can also be specified with the VSPHERE_USER environment variable."
}

variable "vsphere_password" {
  nullable    = true
  type        = string
  description = "This is the password for vSphere API operations. Can also be specified with the VSPHERE_PASSWORD environment variable."
}

variable "vsphere_server" {
  nullable    = true
  type        = string
  description = "This is the vCenter Server FQDN or IP Address for vSphere API operations. Can also be specified with the VSPHERE_SERVER environment variable."
}

variable "vsphere_datacenter" {
  type        = string
  description = "The name of the datacenter. This can be a name or path."
}

variable "vsphere_datastore" {
  type        = string
  description = "The name of the datastore to use."
}

variable "vsphere_cluster" {
  type        = string
  description = "The name of the cluster to use."
}

variable "vsphere_host" {
  type        = string
  description = "The name of the ESXI host. This can be a name or path."
}

variable "vsphere_network_outside" {
  type        = string
  description = "The name of a network that is reachable from the internet."
}

variable "vsphere_network_inside" {
  type        = string
  description = "The name of an internal only network."
}
