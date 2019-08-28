variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = "${var.aws_region}"
}

resource "aws_s3_bucket" "main_domain" {
    bucket  = "tinkerware-staging.com"
    acl     = "public-read"
    policy  = "${file("bucket-policy.json")}"

    website {
        index_document = "index.html"
        error_document = "error.html"
    }
}

resource "aws_s3_bucket" "subdomain_redirect" {
    bucket  = "s3.tinkerware-staging.com"
    acl     = "public-read"

    website {
        redirect_all_requests_to = "tinkerware-staging.com"
    }
}

data "aws_route53_zone" "hosted_zone" {
  name = "tinkerware-staging.com"
}

resource "aws_route53_record" "main_record" {
  zone_id           = "${data.aws_route53_zone.hosted_zone.zone_id}"
  name              = "${aws_s3_bucket.main_domain.bucket}"
  type              = "A"

  alias {
    name                    = "${aws_s3_bucket.main_domain.website_domain}"
    zone_id                 = "${aws_s3_bucket.main_domain.hosted_zone_id}"
    evaluate_target_health  = "true"
  }
}

resource "aws_route53_record" "subdomain_record" {
  zone_id           = "${data.aws_route53_zone.hosted_zone.zone_id}"
  name              = "${aws_s3_bucket.subdomain_redirect.bucket}"
  type              = "A"

  alias {
    name                    = "${aws_s3_bucket.subdomain_redirect.website_domain}"
    zone_id                 = "${aws_s3_bucket.subdomain_redirect.hosted_zone_id}"
    evaluate_target_health  = "true"
  }
}