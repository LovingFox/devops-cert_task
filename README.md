# devops-cert_task

## Certification task of the DevOps Engineer course

[DevOps School](https://devops-school.ru/devops_engineer.html)

Jenkins pipeline to build and deploy a web application on AWS EC2 resources. One instance builds an application, other one starts it.

## Pipeline scheme

![Scheme of the pipeline](scheme.png)

## Pipeline description

### Deploy

* 0 - Jenkins pulls this repository and processes Jenkinsfile
* 1 - Terraform deploys an infrastructure on AWS EC2: two instances (Builder and Webserver)
* 2 - Ansible configures instances
* 3 - Docker builds an application on the Builder instance
* 3a - Docker pushes an artifact container to AWS ECR repository
* 4 - Docker cleans containers on the Webserver instance
* 4a - Docker pulls an artifact from AWS ECR repository and start it

Docker on the Jenkins host uses ssh endpoint to work with remote docker-socket

### Destroy

Terraform just destroy AWS EC2 instances (Builder and Webserver). AWS ECR repository is not touched.

### Parameters

* *appVersion* is a version of the application (default is 1.0)
* *ecrHost* is a hostname of ECR (default is empty)
* *autoApprove* is true or false (default), automatically run Terraform apply after generating plan or user approvement is required
* *destroy* is true or false (default), destroy Terraform build or not

## Files

* *Jenkinsfile* (pipeline)
* *\*.tf* (Terraform files)
* *prepare-instances.yml* (Ansible playbook)
* *Dockerfile, app.py, requirements.txt* (Python application)

### Application

Just a simple *Hello world* web server based on the python flask. It shows version that set by Jenkins parameter *appVersion*.

## Usage

1. Install **aws cli**, **terraform**, **ansible**, **Jenkins** (plugins: SSH Agent, Ansible, Terrafotm)
1. Generate ssh key and import it to the AWS EC2

    ```bash
    ssh-keygen -t rsa -C "aws-ec2-key" -f ~/.ssh/aws-ec2-key
    aws ec2 import-key-pair --key-name devops-cert_task-key --public-key-material fileb://~/.ssh/aws-ec2-key.pub
    ```

1. Create ECR repository

    ```bash
    aws ecr create-repository --repository-name cert_task
    ```

1. Create Jenkins job

   Dashboard -> New job -> type Pipeline, name *devops-cert_task*  
   Pipeline Definition: Pipeline script from SCM, Git  
   Repository URL: [https://github.com/LovingFox/devops-cert_task.git](https://github.com/LovingFox/devops-cert_task.git)

1. Create Jenkins credentials for ssh

   Kind: SSH Username with private key  
   ID: *AWS_UBUNTU_INSTANCE_SSH_KEY*  
   Username: *ubuntu*  
   Key:

    ```bash
    cat ~/.ssh/aws-ec2-key
    ```

1. Create Jenkins credentials for AWS ECR repository

   Kind: SSH Username with private key  
   ID: *AWS_ECR_CREDENTIALS*
   Username: *AWS*  
   Password:

    ```bash
    aws ecr get-login-password
    ```

1. Create Jenkins credentials for AWS API

   Kind: Secret text  
   ID: *AWS_ACCESS_KEY_ID*  
   Secret: \<Your AWS Access Key ID\>  

   Kind: *Secret text*  
   ID: *AWS_SECRET_ACCESS_KEY*  
   Secret: \<AWS Secret Access Key\>  

1. Start Jenkins job by GUI or by cli:

    ```bash
    java -jar jenkins-cli.jar build -v -f devops-cert_task -p autoApprove=true -p appVersion=1.0 -p ecrHost=657846606580.dkr.ecr.eu-central-1.amazonaws.com
    ```

    *657846606580.dkr.ecr.eu-central-1.amazonaws.com* is just an example hostname of ECR, change it by yours

1. Check the application is working:

    ```bash
    cutl http://curl http://<host name>.<region>.compute.amazonaws.com
    ```

   URL of the webserver is prined at the end of the Jenkins job

1. Destroy the infrastructure by GUI or by cli:

    ```bash
    java -jar jenkins-cli.jar build -v -f devops-cert_task -p destroy=true
    ```
