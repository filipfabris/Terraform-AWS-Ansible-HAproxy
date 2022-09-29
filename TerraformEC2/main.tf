provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = var.region
}

#Create aws security group, automatic creates vpc
resource "aws_security_group" "test_security_group" {
    name = "Verso-Test"
    description = "Created via Terraform"

    #In traffic
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #Out traffic
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}

#Create aws instance for haproxy
resource "aws_instance" "haproxy_load_balancer" {
    #security_groups = ["${aws_security_group.test_security_group.name}"] #deprecated 
    vpc_security_group_ids = ["${aws_security_group.test_security_group.id}"]
    instance_type = "${var.load_balancer_instance_type}"
    key_name = "${var.aws_key_name}"
    ami = "${var.load_balancer_ami}"
    count = 1

    # The connection block tells our provisioner how to
    # communicate with the resource (instance)
    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file(var.aws_pem_key_file_path)
        host = self.public_ip
    }

    provisioner "remote-exec" {
        # some `sleep` might be needed to prevent i/o timeout here?
        inline = [
          "sleep 20",
          "sudo su <<EOF",
          "sudo yum update -y > /dev/null",
          "sudo amazon-linux-extras install ansible2 -y",
          "sudo useradd ansible",
          "echo 'ansible ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo",
          "sudo mkdir -p /home/ansible/.ssh",
          "sudo touch /home/ansible/.ssh/authorized_keys",
          "sudo echo '${file(var.aws_pub_key_file_path)}' > /home/ansible/.ssh/authorized_keys",
          "sudo chown -R ansible:ansible /home/ansible/.ssh",
          "EOF"
        ]
    }

    tags = {
        Name = "HAProxyServer"
    }
}

#Create aws instance for apache web
resource "aws_instance" "web" {
    #security_groups = ["${aws_security_group.test_security_group.name}"]
    vpc_security_group_ids = ["${aws_security_group.test_security_group.id}"]
    instance_type = "${var.web_instance_type}"
    key_name = "${var.aws_key_name}"
    ami = "${var.web_ami}"
    count = "${var.desired_web_server_count}"

    connection {
        user = "ec2-user"  #Za OS instancu je drugaciji default user, nije moguc root login
        private_key = file(var.aws_pem_key_file_path)
        host = self.public_ip
    }

    provisioner "remote-exec" {
        # some `sleep` might be needed to prevent i/o timeout here?
        inline = [
          "sleep 20",
          "sudo su <<EOF",
          "sudo yum update -y > /dev/null",
          "sudo amazon-linux-extras install ansible2 -y",
          "sudo useradd ansible",
          "echo 'ansible ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo",
          "sudo mkdir -p /home/ansible/.ssh",
          "sudo touch /home/ansible/.ssh/authorized_keys",
          "sudo echo '${file(var.aws_pub_key_file_path)}' > /home/ansible/.ssh/authorized_keys",
          "sudo chown -R ansible:ansible /home/ansible/.ssh",
          "EOF"
        ]
    }

    tags = {
    Name = "WebServer"
    }
}

# Generate inventory file
resource "local_file" "inventory" {
    filename = "./inventory/inventory.ini"

content = <<EOF
[httpd]
${aws_instance.web[0].public_ip} 
${aws_instance.web[1].public_ip}
[haproxy]
${aws_instance.haproxy_load_balancer[0].public_ip} load_balancer_private_ip=${aws_instance.haproxy_load_balancer[0].private_ip}
EOF

}