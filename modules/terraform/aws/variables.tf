variable "json_input" {
  description = "value of the json input"
  type = object({
    run_id = string
    region = string
  })
}

variable "owner" {
  description = "Owner of the scenario"
  type        = string
  default     = "azure_devops"
}

variable "scenario_name" {
  description = "Name of the scenario"
  type        = string
  default     = ""
}

variable "scenario_type" {
  description = "value of the scenario type"
  type        = string
  default     = ""
}

variable "deletion_delay" {
  description = "Time duration after which the resources can be deleted (e.g., '1h', '2h', '4h')"
  type        = string
  default     = "2h"
}

variable "network_config_list" {
  description = "Configuration for creating the server network."
  type = list(object({
    role           = string
    vpc_name       = string
    vpc_cidr_block = string
    subnet = list(object({
      name                    = string
      cidr_block              = string
      zone_suffix             = string
      map_public_ip_on_launch = optional(bool, false)
    }))
    security_group_name = string
    route_tables = list(object({
      name             = string
      cidr_block       = string
      nat_gateway_name = optional(string)
    }))
    route_table_associations = list(object({
      name             = string
      subnet_name      = string
      route_table_name = string
    }))
    nat_gateway_public_ips = optional(list(object({
      name = string
    })))
    nat_gateways = optional(list(object({
      name           = string
      public_ip_name = string
      subnet_name    = string
    })))
    sg_rules = object({
      ingress = list(object({
        from_port  = number
        to_port    = number
        protocol   = string
        cidr_block = string
      })),
      egress = list(object({
        from_port  = number
        to_port    = number
        protocol   = string
        cidr_block = string
      }))
    })
  }))
  default = []
}

variable "eks_config_list" {
  type = list(object({
    role        = string
    eks_name    = string
    vpc_name    = string
    policy_arns = list(string)
    eks_managed_node_groups = list(object({
      name           = string
      ami_type       = string
      instance_types = list(string)
      min_size       = number
      max_size       = number
      desired_size   = number
      capacity_type  = optional(string, "ON_DEMAND")
      labels         = optional(map(string), {})
      taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })), [])
    }))
    eks_addons = list(object({
      name            = string
      version         = optional(string)
      service_account = optional(string)
      policy_arns     = optional(list(string), [])
    }))
  }))
  default = []
}
