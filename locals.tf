locals {
    account_id = data.aws_caller_identity.current.account_id
    zone_id = data.aws_route53_zone.example.id
    region = data.aws_region.current.name

    subject_alternative_names = ["www.${var.domain_name}", "${var.domain_name}", "media.${var.domain_name}"]
}