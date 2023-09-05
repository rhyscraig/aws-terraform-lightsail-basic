################################################
## Lightsail resources
################################################

// KMS Key
resource "aws_kms_key" "access_key" {
  description             = "${var.domain_name}-${var.region}-kms-key"
  deletion_window_in_days = 10
}


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
  user_data         = local.user_data
  tags              = var.default_tags
}

# Public ports
resource "aws_lightsail_instance_public_ports" "instance_port_http" {
  instance_name = aws_lightsail_instance.lightsail_instance.name

  for_each = { for port in var.security_group_ports : port => port }

  port_info {
    protocol  = "tcp"
    from_port = each.key
    to_port   = each.key
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
  subject_alternative_names = local.subject_alternative_names
  tags                      = var.default_tags
}

# Instance Distribution
resource "aws_lightsail_distribution" "lightsail_distro" {
  name             = "${var.domain_name}-${var.region}-instance-distribution"
  depends_on       = [aws_lightsail_static_ip_attachment.lightsail_ip_attachment]
  bundle_id        = var.instance_distro_bundle_id
  certificate_name = aws_lightsail_certificate.lightsail_cert.id

  origin {
    name        = aws_lightsail_instance.lightsail_instance.name
    region_name = var.region
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

// media bucket
# Bucket
resource "aws_lightsail_bucket" "lightsail_bucket" {
  name      = "${var.domain_name}-${var.region}--media-bucket"
  bundle_id = var.bucket_bundle_id
  tags      = var.default_tags
}
# Bucket access key
resource "aws_lightsail_bucket_access_key" "bucket_access_key" {
  bucket_name = aws_lightsail_bucket.lightsail_bucket.name
}
# bucket resource access
resource "aws_lightsail_bucket_resource_access" "bucket_resource_access" {
  bucket_name   = aws_lightsail_bucket.lightsail_bucket.name
  resource_name = aws_lightsail_instance.lightsail_instance.id
}

# Media Bucket Distribution
resource "aws_lightsail_distribution" "test" {
  name      = "${var.domain_name}-${var.region}--media-distribution"
  bundle_id = "small_1_0"
  origin {
    name        = aws_lightsail_bucket.lightsail_bucket.name
    region_name = aws_lightsail_bucket.lightsail_bucket.region
  }
  default_cache_behavior {
    behavior = "cache"
  }
  cache_behavior_settings {
    allowed_http_methods = "GET,HEAD,OPTIONS,PUT,PATCH,POST,DELETE"
    cached_http_methods  = "GET,HEAD"
    default_ttl          = 86400
    maximum_ttl          = 31536000
    minimum_ttl          = 0
    forwarded_cookies {
      option = "none"
    }
    forwarded_headers {
      option = "default"
    }
    forwarded_query_strings {
      option = false
    }
  }
}
