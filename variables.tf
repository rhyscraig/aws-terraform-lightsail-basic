variable domain_name {
    type = string
    description = "The name of the domain e.g. example"
    default = ""
}

variable domain {
    type = string
    description = "The name of the domain e.g. example.com"
    default = ""
}

variable default_tags {
    type = map(string)
    description = "Default tags to use for resources"
    default = {}
}

variable region {
    type = string
    description = "The region in which to deploy SES"
}

variable region_zone {
    type = string
    description = "The region in which to deploy SES"
}

variable disk_size {
    type = string
    description = "The size of EBS volume to attach"
}

variable instance_bundle_id {
    type = string
    description = "The size of instance bundle"
}

variable blueprint_id {
    type = string
    description = "The type of lightsail instance"
}

variable security_group_ports {
    type = list(string)
    description = "The ports to open in the security group"
}

variable instance_distro_bundle_id {
    type = string
    description = "The flavour of instance software bundle"
}

variable media_distro_bundle_id {
    type = string
    description = "The size of distribution bundle"
}

variable bucket_bundle_id {
    type = string
    description = "The size of the bucket bundle"  
}