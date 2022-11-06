pipeline {
    parameters {
        string(name: "appVersion", defaultValue: "1.0")
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy Terraform build?')
    }

    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {

        ///////////////////////////////
        /// Terrafotm stages
        ///////////////////////////////

        stage('Checkout') {
            steps {
                checkout( [$class: 'GitSCM', branches: [[name: '*/terraform']]] )
            }
        } // stage Checkout

        stage('Plan') {
            when {
                not {
                    equals( expected: true, actual: params.destroy )
                }
            }

            steps {
                sh 'terraform init -input=false'
                sh "terraform plan -input=false -out tfplan"
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        } // stage Plan

        stage('Approval') {
            when {
                not {
                    equals( expected: true, actual: params.autoApprove )
                }
                not {
                    equals( expected: true, actual: params.destroy )
                }
            }

            steps {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        } // stage Approval

        stage('Apply') {
            when {
                not {
                    equals( expected: true, actual: params.destroy )
                }
            }
            
            steps {
                sh "terraform apply -input=false tfplan"
                script {
                    builderDnsName = sh(
                       script: "terraform output -raw builder_dns_name",
                       returnStdout: true
                    ).trim()
                }
            }
        } // stage Apply

        stage('Destroy') {
            when {
                equals( expected: true, actual: params.destroy )
            }
        
            steps {
               sh "terraform destroy --auto-approve"
               script {
                   builderDnsName = ""
               }
            }
        } // stage Destroy

        ///////////////////////////////
        /// Ansible stages
        ///////////////////////////////

        stage('Ansible inventory prepare') {
            steps {
               sh "if [ -f hosts ]; then rm hosts; fi"
               sh "echo '[builder]' >> hosts"
               sh "[ '${builderDnsName}' = '' ] || echo ${builderDnsName}  ansible_user=ubuntu >> hosts"
            }
        } // stage Ansible inventory prepare

        stage('Ansible playbook') {
            steps {
                // ansiblePlaybook(
                //     playbook: 'prepare-instances.yml',
                //     inventory: 'hosts',
                //     credentialsId: 'AWS_UBUNTU_INSTANCE_SSH_KEY',
                //     become: true,
                // )
                sshagent( credentials:['AWS_UBUNTU_INSTANCE_SSH_KEY'] ) {
                    sh "ansible-playbook prepare-instances.yml -i hosts -b --become-user root -u ubuntu"
                }
            }
        } // stage Ansible

    } // stages
}
