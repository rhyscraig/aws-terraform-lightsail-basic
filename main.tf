# Lightsail key pair
resource "aws_lightsail_key_pair" "lg_key_pair" {
  name    = "${var.domain_name}-${var.region}-lg-key-pair"
  tags    = var.default_tags
}

# Create a new Ghost Lightsail Instance
resource "aws_lightsail_instance" "lightsail_instance" {
  name              = "${var.domain_name}-${var.region}-instance"
  availability_zone = var.region
  blueprint_id      = var.blueprint_id
  bundle_id         = var.instance_bundle_id
  key_pair_name     = aws_lightsail_key_pair.lg_key_pair.name
  user_data         = var.user_data
  tags              = var.tags
}

# Public ports
resource "aws_lightsail_instance_public_ports" "instance_port_http" {
  instance_name = aws_lightsail_instance.lightsail_instance.name

  for_each = { for port in var.security_group_ports : ip => ip }

  port_info {
    protocol  = "tcp"
    from_port = [each.key]
    to_port   = [each.key]
  }

}

# Disk lookup
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Disk
resource "aws_lightsail_disk" "lightsail_disk" {
  name              = "${var.domain_name}-${var.region}-disk"
  size_in_gb        = var.disk_size
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = var.default_tags
}

# Disk attachment
resource "aws_lightsail_disk_attachment" "lightsail_disk" {
  disk_name     = aws_lightsail_disk.lightsail_disk.name
  instance_name = aws_lightsail_instance.lightsail_instance.name
  disk_path     = "/dev/xvdf"
}

# IP
resource "aws_lightsail_static_ip" "lightsail_ip" {
  name = "${var.domain_name}-${var.region}-static-ip"
}

# IP Attacahment
resource "aws_lightsail_static_ip_attachment" "lightsail_ip_attachment" {
  static_ip_name = aws_lightsail_static_ip.lightsail_ip.id
  instance_name  = aws_lightsail_instance.lightsail_instance.id
}

# Lightsail certificate
resource "aws_lightsail_certificate" "lightsail_cert" {
  name                      = "${var.domain_name}-${var.region}-certificate"
  domain_name               = var.domain
  subject_alternative_names = var.subject_alternative_names
  tags                      = var.default_tags
}

# Distribution
resource "aws_lightsail_distribution" "lightsail_distro" {
  name             = "${var.domain_name}-${var.region}-instance-distribution"
  depends_on       = [aws_lightsail_static_ip_attachment.lightsail_ip_attachment]
  bundle_id        = var.distro_bundle_id
  certificate_name = aws_lightsail_certificate.lightsail_cert.id

  origin {
    name        = aws_lightsail_instance.lightsail_instance.name
    region_name = var.region_name
  }

  default_cache_behavior {
    behavior = "cache"
  }

  tags = var.default_tags
}

# Domain entry
resource "aws_lightsail_domain_entry" "domain" {
  domain_name = var.domain
  name        = "${var.domain_name}.com"
  type        = "A"
  is_alias    = true
  target      = aws_lightsail_distribution.lightsail_distro.domain_name
}

# Domain entry
resource "aws_lightsail_domain_entry" "domain_www" {
  domain_name = var.domain
  name        = "www.${var.domain_name}.com"
  type        = "A"
  is_alias    = true
  target      = aws_lightsail_distribution.lightsail_distro.domain_name
}