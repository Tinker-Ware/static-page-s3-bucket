variable "bucket_name" {
  type = "string"
  description = "Name for the bucket and the domain which will be used to access the website"
}

variable "create_www_bucket" {
  type = bool
  description = "Conditional to create or not the resources needed for the www subdomain"
}
