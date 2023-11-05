variable "web-srvs_ip" {    
    description = "Webserver IP"
    type = list(string)
}
variable "haproxy_ip" {
    description = "HaProxy Fixed IP"
}

variable "ansible_ip" {
    description = "Ansible Control Server Fixed IP"
}

variable "centos" {
    description = "My Openstack Centos Image"
    type = string
}

variable "m1_large" {
    description = "My Openstack m1.large flavor"
}

variable "network" {
    description = "My Openstack Network"
  
}

variable "subnet" {
    description = "My Openstack network subnet"
}

variable "all_ip" {
    description = "All IP 0.0.0.0/0"  
}

variable "internal_subnet" {
    description = "MY Internal Subnet 192.168.1.0/24" 
}

variable "common_tags" {
    description = "Common tag to apply all resources"
    type = list(string)
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}