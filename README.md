# S3 Buckets to host your static webpage
## Summary
This repo allows you to host your static webpage in a S3 Bucket from AWS, linking it with a domain from Route53 so it's easier to access (and remember the name). This simplifies the tasks you have to do to see your website running and available for anyone on the web, more or less, the repository where the static files of your website are allocated should have:   
> Static files folder   
> index.html   
> error.html

## Requirements:
- Ansible 2.8.1 or higher
- Terraform 0.12.6 or higher
    - AWS provider 2.25.0 or higher
    - Null provider 2.1.2 or higher
- The next two environment variables, set with the corresponding values for your account:
    - AWS_ACCESS_KEY
    - AWS_SECRET_KEY

## How to use
1) Add the needed variables in `ansible-s3-static-page-upload-role/vars/main.yml` if you need different values from the default ones.
    1.1) If you changed the `bucket_name` variable value, set the same value for that variable in `terraform.tfvars`
2) If you don't wan't to create an extra S3 bucket for the `www` subdomain, change `create_www_bucket` to `false` inside `terraform.tfvars`
3) Run `terraform apply` and wait for it to finish
4) Visit the URL set for the `bucket_name` variable in Ansible and Terraform variables files to see your website running!