scenario_type  = "perf-eval"
scenario_name  = "disk-attach-dettach"
deletion_delay = "2h"
network_config_list = [
  {
    role           = "helper"
    vpc_name       = "helper-vpc"
    vpc_cidr_block = "10.0.0.0/16"
    subnet = [{
      name        = "helper-subnet"
      cidr_block  = "10.0.0.0/24"
      zone_suffix = "a"
    }]
    security_group_name      = "helper-sg"
    route_tables             = [],
    route_table_associations = []
    sg_rules = {
      ingress = []
      egress  = []
    }
  }
]

vm_config_list = [{
  vm_name                     = "helper-vm"
  role                        = "helper"
  subnet_name                 = "helper-subnet"
  security_group_name         = "helper-sg"
  associate_public_ip_address = true
  zone_suffix                 = "a"
}]

data_disk_config = {
  zone_suffix = "a"
}

loadbalancer_config_list = []