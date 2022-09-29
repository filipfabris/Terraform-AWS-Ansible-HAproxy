# Terraform-KeyPair
Terraform project for creating AWS key-pairs

`main.tf` will:
* use `tls_private_key` resource to create RSA keys
* use `local_file` resource to create `.pub` public and `.pem` private keys locally
* use `aws_key_pair` resource to bind created public key on AWS 


Before all populate following variables inside `terraform.tfvars`:
 * `aws_access_key` - AWS key ID
 * `aws_secret_key` - AWS key secret

Also look up for `region variable` inside `variables.tf`

### Step 1: Edit main.tf
Inside local_file resources you can name your private and public key as you want, by default:\
`filename = "verso_key.pem"`\
`filename = "verso_key.pub"` 

Inside aws_key_pair resource you can change name how key pair will be called on AWS

### If you change default names of keys you have to change `terraform.tvars` inside `TerraformEC2` and `ansible.cfg` inside `Ansible` folder 

### Step 2: Start terraform project - create AWS key-pair
```bash
terraform init
terraform validate
terraform apply
```

## Authors
Created in 2022 by [Filip Fabris](https://github.com/filipfabris)

