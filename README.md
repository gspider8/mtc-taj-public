## DevOps in the Cloud with Terraform, Ansible and Jenkins
This project was created through the course of the same name by Derek Morgan
links
  - [course github](https://github.com/morethancertified/devops-in-the-cloud)
  - [course link](https://courses.morethancertified.com/p/devops-in-the-cloud)
  - [my certificate](bin/course-certificate.pdf)
  - [my walkthrough](walkthrough.md)

### In this course I learned
  - More terraform skills such as data sources, count loops, variables, and outputs 
    - `compute.tf`, `networking.tf` 
  - How to bootstrap a new EC2 instance with an Ansible playbook 
    - `playbooks/main-playbook.yml`
  - How to create a Jenkins Pipeline and how to utilize a Jenkinsfile 
    - `Jenkinsfile`
  - How to use loops in Ansible playbooks to verify instance port status 
    - `playbooks/node-test.yml`
  - How to utilize the various ways to store variables in Terraform
    - `dev.tfvars` and `main.tfvfars` for different git branches
    - `variables.tf` for general, static variables
    - `local` for simplifying long strings of code
  - How to configure a GitHub webhook to post new commits to Jenkins and create a build