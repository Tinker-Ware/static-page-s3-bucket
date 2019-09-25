variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = "${var.aws_region}"
}

resource "aws_s3_bucket" "main_domain" {
  bucket  = "${ var.bucket_name }"
  acl     = "public-read"
  policy  = "${file("bucket-policy.json")}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "subdomain_redirect" {
  count = "${ var.create_www_bucket ? 1 : 0 }"

  bucket  = "www.${ var.bucket_name }"
  acl     = "public-read"

  website {
    redirect_all_requests_to = "${ var.bucket_name }"
  }
}

data "aws_route53_zone" "hosted_zone" {
  name = "${ var.bucket_name }"
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
  count = "${ var.create_www_bucket ? 1 : 0 }"

  zone_id           = "${data.aws_route53_zone.hosted_zone.zone_id}"
  name              = "${aws_s3_bucket.subdomain_redirect[0].bucket}"
  type              = "A"

  alias {
    name                    = "${aws_s3_bucket.subdomain_redirect[0].website_domain}"
    zone_id                 = "${aws_s3_bucket.subdomain_redirect[0].hosted_zone_id}"
    evaluate_target_health  = "true"
  }
}

resource "null_resource" "provision1" {
    depends_on = [aws_s3_bucket.main_domain]
    provisioner "local-exec" {
      command = "ansible-playbook main.yml"
      
    }
}
