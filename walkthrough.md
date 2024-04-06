  - Set up variables in public.tf
  - For repeatability, create this project through AWS Cloud9
  - Always make sure aws_hosts has no ip addresses on it before commiting


### SSHing into our EC2 instance
find public ip: <public_ip>

```sh
ssh -i ~/.ssh/<key_name> ubuntu@<public_ip>
```

## Ansible
One of the goals of ansible is to run the same command on thousands of machines simultaneously 

### Install Ansible
```sh
sudo apt update
sudo apt -y install software-properties-common
sudo add-apt-repository -y --update ppa:ansible/ansible
sudo apt -y install ansible
ansible --version
```
```sh
ansible localhost -m ping #ensures ansible is ready to go
```

### Update Ansible Files

#### Inventory File `ansible/hosts`
```sh
sudo vim /etc/ansible/hosts
```
```
[hosts]
localhost
[hosts:vars]
ansible_connection=local
ansible_python_interpreter=/usr/bin/python3
```
 - `esc` `:wq` to save

#### Configuration File `ansible/ansible.cfg`
```sh
sudo vim /etc/ansible/ansible.cfg 
```
```
# etc/ansible.ansible.cfg
[defaults]
host_key_checking = False

retry_files_enabled = True
retry_files_save_path = ~/environment/mtc-taj/.ansible-retry
```
 - run: `ansible localhost -m ping` and make sure there are no errors


## Jenkins
### Install Jenkins on cloud9 instance
 - this is how you will manage your deployments
```sh
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Select `Install Suggested Plugins`
Create new user and password

### Add additonal plugins
`Manage Jenkins` > `Plugins` > `Available` > `Install without Restart`
 - Ansible
 - Pipeline-AWS (Pipeline: AWS Steps)
 - 
 

### Set up Github App
https://github.com/jenkinsci/github-branch-source-plugin/blob/master/docs/github-app.adoc
 1. Create new repository `mtc-taj`
 2. Account Settings > Developer Settings > New Github App
    2.1. name: mtc-taj, Homepage URL: https://github.com/gspider8, expire auth: false
    2.2. webhook: active, url: http://<c9-elastic-ipv4>:8080/github-webhook 
           - Note: wherever you are viewing jenkins/github-webhook
    2.3. permissions: read only: metadata, contents; read and write: commit statuses 
    2.4. Subscribe to all events; only this acct; create
    2.5. Scroll down to bottom and create private key and download local ssh folder
 3. Drag and drop file into c9 environment directory .. from mtc-taj
 4. cd to that directory and change the key into a format that jenkins will understand
    ```sh
    openssl pkcs8 -topk8 -inform PEM -outform PEM -in <filename> -out converted-github-app.pem -nocrypt
    openssl pkcs8 -topk8 -inform PEM -outform PEM -in mtc-taj.2024-03-28.private-key.pem -out converted-github-app.pem -nocrypt
    ```
 5. Go back to Github, top of page, install app to all repositories
 6. Manage Jenkins > Manage Credentials > System > Global Credentials > Add Credentials
    6.1. Kind: Github App; ID: github-app-mtc-taj; Desc: whatever; App ID: GAID
    6.2. Find GAID:  Github APP Settings
    6.3. Add Key: Copy and paste everything from converted-github-app.pem
    6.4. Create, Test (Cred > Update)


## Refactor environment
terraform destroy
things outside of git environment
 - github app keys 
 - .ansible-retry directory
 

### Refactor credentials
#### AWS
```sh
# aws credentials location - Cloud9
cat /home/ubuntu/.aws/credentials
# update providers.tf
```

#### Terraform
```sh
# terraform credentials location - Cloud9
cat /home/ubuntu/.terraform.d/credentials.tfrc.json    
```
Jenkins > Manage > Credentials > global > add
    Kind: secret file
    File: output from cat saved to a tf-credentials.txt ( save on pc )
    id: tf-creds
    desc: ---

## Jenkins Pipelines

### 1st pipeline
Jenkins Dashboard > New Item > Freestyle Project 
 - name: "mtc-test"
 - source code management: git repo link, credentials
 - branch: main 
 - add build step: execute shell: ls
 - save and apply
 - 
 
Dashboard > mtc-test > build now
 -  can see listing of github files in that directory, can be viewed in c9
 -  
 
Add Terraform Cloud Config
mtc-test > configure > build environment > use secret tests or files
 - type: secret file
 - variable: TF_CLI_CONFIG_FILE (https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_cli_config_file)
 - terraform credentials file
Add cd && terraform init to shell execution
 

### notes on jenkins deployment
 - in c9 cd into /var/lib/jenkins/workspace/mtc-test and run terraform destroy
 - we don't want to run early build steps every time, git pulls,

### Ansible through Jenkins
mtc-test > New build step > Invoke Ansible Playbooks
 - Directory
 - file or hostlist: terraform/aws_hosts
 - Credentials > Add > Jenkins
    - kind: ssh username with private key
    - id: ec2-ssh-key
    - desc: Key for bootstrapping ec2 instances
    - username: ubuntu
    - private key > enter directly
        - `cat ~/.ssh/taj-key`
        - copy all in
    - then choose it
 - become: true

## pipline as code

### Set up github webhooks
https://github.com/gspider8/mtc-taj > Settings > webhooks> add
 - payload URL: http://<localhost_ip>:8080/github-webhook/ 
    - do not forget trailing `/` !!!
 - content-type: application/json
 - events: pushes & pull requests
 - active: true

### Create new Jenkins Pipeline
 - New item
    - name: mtc-taj-pipeline
    - type: Multibranch Pipeline
 - Branch Source: Github
    - credentials
    - https url: https://github.com/gspider8/mtc-taj.git
    - validate
 - Orphaned Item Strategy
    - max # of old items to keep: 5
 - Save

### Create Jenkins File
 - cd doesn't work w pipelines, move terraform file contents do base diretory

### update ec2 security group
update inbound ips to allow github webhook IPs 140.82.112.0/20

#### other github webhook ips

    "192.30.252.0/22",
    "185.199.108.0/22",
    "140.82.112.0/20",
    "143.55.64.0/20",
    

### Set up dev and main branch / jenkinsfile / .tfvars 
 - Create a `main.tfvars` and a `dev.tfvars` file as a copy of terraform.tfvars
 - `git checkout -b dev`
 - Add `$BRANCH_NAME.tfvars` to Jenkinsfile
 - after dev is done `git checkout dev` `git merge dev`