# Terraform-AWS-Ansible-HAproxy
Project consists of three following folders:
* `TerraformKEY` which consits of terraform module which will create `AWS key-pairs` 
* `TerraformEC2` which consits of terraform module which will create one instance for `haproxy` and two instances for `Apache servers`
*  `Ansible` which consists of ansible playbook will install and configure httpd and haproxy config files

# Step 1. TerraformKEY 
Terraform project for creating AWS key-pairs

### What will TerraformKEY do:
`main.tf` will:
* use `tls_private_key` resource to create RSA keys
* use `local_file` resource to create `.pub` public and `.pem` private keys locally
* use `aws_key_pair` resource to bind created public key on AWS 

### Notes

Before all populate following variables inside `terraform.tfvars`:
 * `aws_access_key` - AWS key ID
 * `aws_secret_key` - AWS key secret

### Step 1.1:

#### Edit main.tf
Inside `local_file` resources you can name your private and public key as you want, by\

Default:\
`filename = "verso_key.pem"`\
`filename = "verso_key.pub"` 

Inside `aws_key_pair` resource you can change `key_name`,  name of key pair which will be uploaded on AWS


Default:\
`key_name = "verso_key"`

#### If you change default names of keys you have to change `terraform.tvars` inside `TerraformEC2` and `ansible.cfg` inside `Ansible` folder 

### Step 1.2: Start terraform project - create AWS key-pair
```bash
terraform init
terraform validate
terraform apply
```

### Step 1.3:
#### Copy .pem and .pub keys inside TerraformEC2 folder
#### Copy .pub key inside Ansible folder
We will use them for ssh login to aws EC2 instances 

# Step 2. TerraformEC2 
Terraform project for creating AWS EC2 instances

### What will TerraformKEY do:

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

### Notes

Before all populate following variables inside `terraform.tfvars`:
 * `aws_access_key` - AWS key ID
 * `aws_secret_key` - AWS key secret

### Step 2.1:
Before all populate following variables inside `terraform.tfvars`:
 * `aws_access_key` - AWS key ID
 * `aws_secret_key` - AWS key secret
 * `aws_pem_key_file_path` - AWS private key pair (Will be generated in TerraformKEY)
 * `aws_pub_key_file_path` - AWS public key pair (Will be generated in TerraformKEY)
 * `aws_key_name` - Name of AWS key pair (Will be generated in TerraformKEY)
#### You had to copy .pub and .pem keys generated from TerraformKEY to TerraformEC2 folder
#### By default:
```
aws_pem_key_file_path = "./verso_key.pem"
aws_pub_key_file_path = "./verso_key.pub"
aws_key_name = "verso_key"
```
#### Or you can specify "./../TerraformKEY/verso_key.pem" but i want to modulate this project for later use


### Step 2.2: Modify variables.tf
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


### Step 2.3: Start terraform project - create EC2 instances
```bash
terraform init
terraform validate
terraform apply
```

### Step 2.4:
#### Copy created inventory folder to Ansible folder

# Step 3. Ansible playbook 
Tested on: `RedHat 8` \
Ansible project for installation and configuration of HAproxy service and httpd

### What will TerraformKEY do:

* Based on group httpd run.yml playbook will gather ip-address of web servers bassed on this variable:\
     ` httpd_servers_ips:  '{{groups[''httpd'']}}'` 
* Later inside haproxy role `./roles/haproxy/defaults/main.yml` list variable `haproxy_backend_servers` will be populated using jinja2 for loop: 
    ```jinja2
    haproxy_backend_servers: |
        [
        {% for item in httpd_servers_ips %}
        {"name": "web{{loop.index0}}", "address": "{{item}}:80"},
        {% endfor %}
        ]
    ```
* This variable is used in `./roles/haproxy/templates/haproxy.cfg.j2` to list backend servers for load balancing

### Notes - do not need to edit anything

 * Inside `run.yml` `httpd_ip` variable is overloaded from group_vars with: `httpd_ip: '{{inventory_hostname}}'`

This variable is used in `./roles/httpd/templates/indey.html.cfg.j2` to simply display ip address of current web instance - for testing

 * Also inside `run.yml` `haproxy_ip` variable is overloaded from group_vars with: `haproxy_ip: '{{inventory_hostname}}'`
This variable is used in `./roles/httpd/defaults/main.yml` for haproxy_frontend_bind_address (binding frontend ip address)

* `httpd_servers_ips` variable is also overloaded, its function is explained at the start of this readme


### Step 3.1: Modify ansible.cfg
 * `remote_user` - inside TerraformEC2 ansible sudo ansible user is created, so leave it by default
 * `private_key_file` - path to private key generated by TeraformKEY, remote_user will use it to login on target machine
 #### You had to copy .pub key generated from TerraformKEY to Ansible folder

### Step 3.2: Look for inventory.ini inside ./inventory/inventory.ini
  * inside `[httpd]` there are IP addresses to which appache server will be installed
  * inside `[haproxy]`there is IP address to which HAproxy server will be installed
#### You had to copy whole folder inventory generated inside TerraformEC2 folder and paste it inside Ansible folder

### Step 3.3: Modify variables inside roles haproxy/defaults/main.yml
 * `haproxy_frontend_bind_address` - frontend ip address of HAproxy machine \
 * `haproxy_backend_servers` - backend servers who will handle tasks, example Apache server /httpd

### Step 3.4: Check Ansible playbook
```bash
ansible-playbook run.yml --check -vvv
```

### Step 3.5: Start Ansible playbook
```bash
ansible-playbook run.yml -v
```

# Step 4. Testing
Inside your browser you can put public ip address haproxy server, it should load balance using roundrobin method

#### You can find ip address inside inventory.ini
```
    [httpd]
    3.87.231.82 
    54.227.86.102
    [haproxy]
    107.21.5.247 <--------    load_balancer_private_ip=172.31.90.19
```

## Author
Role created in 2022 by [Filip Fabris](https://github.com/filipfabris)

