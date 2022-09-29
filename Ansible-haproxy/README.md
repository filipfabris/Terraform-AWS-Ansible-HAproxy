# Ansible-HAproxy-Roles-Automation
Tested on: `RedHat 8` \
Ansible project for installation and configuration of HAproxy service


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

### Notes - how to use/modify

 * Inside `run.yml` `httpd_ip` variable is overloaded from group_vars with: `httpd_ip: '{{inventory_hostname}}'`
This variable is used in `./roles/httpd/templates/indey.html.cfg.j2` to simply display ip address of current web instance - for testing

 * Also inside `run.yml` `haproxy_ip` variable is overloaded from group_vars with: `haproxy_ip: '{{inventory_hostname}}'`
This variable is used in `./roles/httpd/defaults/main.yml` for haproxy_frontend_bind_address (binding frontend ip address)

* `httpd_servers_ips` variable is also overloaded, its function is explained at the start of this readme

### Step 1: Create SSH key
 * Create own ssh-key `ssh-keygen -t ed25519`
    Inside `ls ~/.ssh/` are created 
    id `ed25519.pub` (public) and  `id_ed25519` (private) key

* Copy `id_ed25519.pub` to target machine

### Step 2: Modify ansible.cfg
 * `remote_user` - ansible login user to which you have created and copyed id_ed25519.pub public key \
 * `private_key_file` - path to id_ed25519 private key, remote_user will use it to login on target machine

### Step 3: Modify inventory.ini
  * inside `[httpd]` put ip IP addresses to which appache server will be installed
  * inside `[haproxy]` put ip IP address to which HAproxy server will be installed

### Step 4: Modify variables inside roles haproxy/defaults/main.yml
 * `haproxy_frontend_bind_address` - frontend ip address of HAproxy machine \
 * `haproxy_backend_servers` - backend servers who will handle tasks, example Apache server /httpd

### Step 5: Check Ansible playbook
```bash
ansible-playbook run.yml --check -vvv
```

### Step 6: Start Ansible playbook
```bash
ansible-playbook run.yml -v
```
## Authors
Role created in 2022 by [Filip Fabris](https://github.com/filipfabris)

