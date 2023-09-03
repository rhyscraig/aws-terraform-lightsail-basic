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

variable subject_alternative_names {
    type = list(string)
    description = "alternate domain names for certificate"
    default = []
}

variable blueprint_id {
    type = string
    description = "The blueprint id"
    default = ""
}

variable instance_bundle_id {
    type = string
    description = "The bundle id or size of instance"
    default = ""
}

variable disk_size {
    type = string
    description = "the size of lightsail disk"
    default = ""
}

variable security_group_ports {
    type = list(string)
    description = "list of ports to open"
    default = []
}