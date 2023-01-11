terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.35.0"
    }
  }
}

variable "network_id" {
  type = string
}

variable "image_id" {
  type = string
}
variable "key_pair" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "nms_password" {
  type = string
  sensitive = true
  default = "admin"
}

variable "nms_cluster_name" {
  type = string
  default = "cluster"
}

resource "random_password" "clickhouse" {
  length           = 16
}

resource "openstack_networking_port_v2" "management-suite-port" {
  network_id = var.network_id
  name       = "management-suite"
}

resource "openstack_compute_instance_v2" "management-suite-server" {
  name        = "management-suite"
  image_id    = var.image_id
  key_pair    = var.key_pair
  flavor_name = "m1.medium"

  provisioner "remote-exec" {
    inline = ["rm /etc/apt/sources.list.d/google-cloud-sdk.list"]

    connection {
      host        = self.access_ip_v4
      type        = "ssh"
      user        = "root"
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    command = "NMS_CH_PASSWORD='${random_password.clickhouse.result}' NMS_PASSWORD='${var.nms_password}' NMS_CLUSTER_NAME='${var.nms_cluster_name}' NMS_CLUSTER_HOST='${openstack_networking_port_v2.data-plane-port.all_fixed_ips[0]}' NMS_DEV_CLUSTER_NAME='${var.nms_cluster_name}-dev' NMS_DEV_CLUSTER_HOST='${openstack_networking_port_v2.developer-portal-port.all_fixed_ips[0]}' ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.access_ip_v4},' --private-key ${var.private_key_path} management-suite.playbook.yml"
  }

  network {
    port = openstack_networking_port_v2.management-suite-port.id
  }
}

resource "openstack_networking_port_v2" "developer-portal-port" {
  network_id = var.network_id
  name       = "developer-portal"
}

resource "openstack_compute_instance_v2" "developer-portal-server" {
  name        = "developer-portal"
  image_id    = var.image_id
  key_pair    = var.key_pair
  flavor_name = "m1.medium"

  provisioner "remote-exec" {
    inline = ["rm /etc/apt/sources.list.d/google-cloud-sdk.list"]

    connection {
      host        = self.access_ip_v4
      type        = "ssh"
      user        = "root"
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    command = "NMS_HOST=${openstack_compute_instance_v2.management-suite-server.access_ip_v4} NMS_DEV_CLUSTER_NAME='${var.nms_cluster_name}-dev' ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.access_ip_v4},' --private-key ${var.private_key_path} developer-portal.playbook.yml"
  }

  network {
    port = openstack_networking_port_v2.developer-portal-port.id
  }
}

resource "openstack_networking_port_v2" "data-plane-port" {
  network_id = var.network_id
  name       = "data-plane"
}

resource "openstack_compute_instance_v2" "data-plane-server" {
  name        = "data-plane"
  image_id    = var.image_id
  key_pair    = var.key_pair
  flavor_name = "m1.medium"

  provisioner "remote-exec" {
    inline = ["rm /etc/apt/sources.list.d/google-cloud-sdk.list"]

    connection {
      host        = self.access_ip_v4
      type        = "ssh"
      user        = "root"
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    command = "NMS_HOST=${openstack_compute_instance_v2.management-suite-server.access_ip_v4} NMS_CLUSTER_NAME=${var.nms_cluster_name} ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.access_ip_v4},' --private-key ${var.private_key_path} data-plane.playbook.yml"
  }

  network {
    port = openstack_networking_port_v2.data-plane-port.id
  }
}

output "ip_addresses" {
  value = {
    management-suite = openstack_compute_instance_v2.management-suite-server.access_ip_v4
    data-plane = openstack_compute_instance_v2.data-plane-server.access_ip_v4
    developer-portal = openstack_compute_instance_v2.developer-portal-server.access_ip_v4
  }
}
