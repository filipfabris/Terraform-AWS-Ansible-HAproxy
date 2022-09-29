# Terraform-AWS
Terraform project for creating AWS EC2 instances

`main.tf` will create:
* one aws instance for load load_balancer
* two aws instances for web servers
* it will create `sudo ansible` user on all aws instances
* `./inventory/inventory.ini` file will be created for ansible playbook which will contain public ip addresses of created instances

Final product of `resource "local_file" "inventory"`:
```
    [httpd]
    3.87.231.82 
    54.227.86.102
    [haproxy]
    107.21.5.247 load_balancer_private_ip=172.31.90.19
```

Command of `provisioner "remote-exec"`:
```bash
    sleep 20                            #Prevent i/o timeout
    sudo su <<EOF                       #Have to put <<EOF, terraform execute problem if sudo su is used
    sudo yum update -y > /dev/null
    sudo amazon-linux-extras install ansible2 -y
    sudo useradd ansible
    echo 'ansible ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo
    sudo mkdir -p /home/ansible/.ssh
    sudo touch /home/ansible/.ssh/authorized_keys
    sudo echo '${file(var.aws_pub_key_file_path)}' > /home/ansible/.ssh/authorized_keys
    sudo chown -R ansible:ansible /home/ansible/.ssh
    EOF"                                #Escape from sudo su after this 
```

# VM Provisioning
Before all populate following variables inside `terraform.tfvars`:
 * `aws_access_key` - AWS key ID
 * `aws_secret_key` - AWS key secret
 * `aws_pem_key_file_path` - AWS private key pair (Will be generated in TerraformKEY)
 * `aws_pub_key_file_path` - AWS public key pair (Will be generated in TerraformKEY)
 * `aws_key_name` - Name of AWS key pair (Will be generated in TerraformKEY)

### Step 1: Modify variables.tf
* Select your own region

 ```
 variable "region" {
    description = "AWS Region"
    type = string
    default = "us-east-1"   <----
}
```

* For each region there are different AMI instances, find on AWS console panel

```
variable "web_ami" {
    description = "AMI for Web instances"
    type = string
    default = "ami-05fa00d4c63e32376"   <----
}
```

* Select instance type

```
variable "web_instance_type" {
    description = "Instance type for Web instances"
    type = string
    default = "t2.micro"   <----
}
``` 

Same for variable `load_balancer`


### Step 2: Start terraform project - create EC2 instances
```bash
terraform init
terraform validate
terraform apply
```


### Step 3: Terminate EC2 instances -- after all tests
```bash
terraform destroy 
```


## Author
Created in 2022 by [Filip Fabris](https://github.com/filipfabris)

