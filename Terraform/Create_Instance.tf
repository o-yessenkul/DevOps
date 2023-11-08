# Define required providers
terraform {
required_version = ">= 1.5.1"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

provider "openstack" {
    tenant_name = "DevOps"
    auth_url   = "http://10.12.146.22:5000"
    region     = "regionOne"
}

resource "openstack_networking_network_v2" "Internal1" {
  name           = "Internal1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "Subnet1" {
  network_id = openstack_networking_network_v2.Internal1.id
  cidr       = var.internal_subnet
  ip_version = 4
  gateway_ip = var.int_gateway_ip
  enable_dhcp = true
  dns_nameservers = var.dns-servers
  allocation_pool {
    start = var.dhcp_start_ip
    end = var.dhcp_end_ip
  }
  tags = var.common_tags
}

resource "openstack_networking_router_v2" "Router1" {
  name                = "Router1"
  external_network_id = var.Public_Net_id
}

resource "openstack_networking_router_interface_v2" "R1_interface" {
  router_id = openstack_networking_router_v2.Router1.id
  subnet_id = openstack_networking_subnet_v2.Subnet1.id
}

 
resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = "Security Group for Web_Servers"
  description = "My neutron security group for Web Servers"
  tags = concat(var.common_tags, ["Name= Security Group for Web_Servers Build by terraform"])
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = var.internal_subnet
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.http_port
  port_range_max    = var.http_port
  remote_ip_prefix  = var.internal_subnet
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = var.all_ip
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}

resource "openstack_networking_secgroup_v2" "secgroup_2" {
  name        = "Security Group for HA-Proxy"
  description = "My neutron security group for HA-Proxy"
  tags = concat(var.common_tags, ["Name= Security Group for Ha-Proxy Build by terraform"])
 
}

resource "openstack_networking_secgroup_rule_v2" "sec_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = var.internal_subnet
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_2.id}"
}

resource "openstack_networking_secgroup_rule_v2" "sec_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.http_port
  port_range_max    = var.http_port
  remote_ip_prefix  = var.all_ip
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_2.id}"
}

resource "openstack_networking_secgroup_rule_v2" "sec_rule_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = var.all_ip
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_2.id}"
}

resource "openstack_networking_secgroup_v2" "secgroup_3" {
  name        = "Security Group for Ansible"
  description = "My neutron security group for Ansible-Control Server"
  tags = concat(var.common_tags, ["Name= Security Group for Ansible Build by terraform"])
   
}

resource "openstack_networking_secgroup_rule_v2" "sec_rule_control_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = var.all_ip
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_3.id}"
}


resource "openstack_networking_secgroup_rule_v2" "sec_rule_control_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = var.all_ip
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_3.id}"
}


resource "openstack_networking_port_v2" "ctl_srv_port" {
  network_id = openstack_networking_network_v2.Internal1.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.Subnet1.id
    ip_address = var.ansible_ip 
  }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_3.id]
}


resource "openstack_networking_port_v2" "web-srvs_port" {  
  count                   = length(var.web-srvs_ip)
  network_id = openstack_networking_network_v2.Internal1.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.Subnet1.id  
    ip_address = element(var.web-srvs_ip, count.index) 
  }
    security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_port_v2" "ha-proxy_port" {
  network_id = openstack_networking_network_v2.Internal1.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.Subnet1.id
    ip_address = var.haproxy_ip 
  }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_2.id]
}


resource "openstack_compute_instance_v2" "Ansible-Srv" {
    name         = "Ansible-Srv"
    image_id     = var.centos
    flavor_id    = var.m1_large
    key_pair     = "olzhas-admin"
    user_data= file("ansible_setup.sh")

    tags = concat(var.common_tags, ["Name=Ansible Control Server Build by terraform"])

    block_device {
        uuid                  = var.centos
        source_type           = "image"
        destination_type      = "local"
        boot_index            = 0
        delete_on_termination = true
    }
    
    block_device {
        source_type           = "blank"
        destination_type      = "volume"
        volume_size           = 70
        boot_index            = 1
        delete_on_termination = true
    }
    network {
        port = openstack_networking_port_v2.ctl_srv_port.id  
    }
}

resource "openstack_compute_instance_v2" "Web-Server" {
    count        = length(var.web-srvs_ip)
    name         = "Web-Server-${count.index + 1}"
    image_id     = var.centos
    flavor_id    = var.m1_large
    key_pair     = "olzhas-admin"
    user_data= file("web-servers.sh")

    tags = concat(var.common_tags, ["Name=Web Server Build by terraform"])

    block_device {
        uuid                  = var.centos
        source_type           = "image"
        destination_type      = "local"
        boot_index            = 0
        delete_on_termination = true
    }
    
    block_device {
        source_type           = "blank"
        destination_type      = "volume"
        volume_size           = 70
        boot_index            = 1
        delete_on_termination = true
    }
    network {
        port = element(openstack_networking_port_v2.web-srvs_port[*].id, count.index) 
    }
}


resource "openstack_compute_instance_v2" "HA-Proxy" {
    name         = "HA-Proxy"
    image_id     = var.centos
    flavor_id    = var.m1_large
    key_pair     = "olzhas-admin"

    tags = concat(var.common_tags, ["Name=Ha Proxy Server Build by terraform"])

    block_device {
        uuid                  = var.centos
        source_type           = "image"
        destination_type      = "local"
        boot_index            = 0
        delete_on_termination = true
    }
    
    block_device {
        source_type           = "blank"
        destination_type      = "volume"
        volume_size           = 70
        boot_index            = 1
        delete_on_termination = true
    }
    network {
        port = openstack_networking_port_v2.ha-proxy_port.id  
    }
}


resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "Public"
}

resource "openstack_networking_floatingip_v2" "fip_2" {
  pool = "Public"
}
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.HA-Proxy.id
}

resource "openstack_compute_floatingip_associate_v2" "fip_2" {
  floating_ip = openstack_networking_floatingip_v2.fip_2.address
  instance_id = openstack_compute_instance_v2.Ansible-Srv.id
}

