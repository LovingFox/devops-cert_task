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

        stage('Set variables') {
            steps {
                script {
                    sshCredsID = 'AWS_UBUNTU_INSTANCE_SSH_KEY'
                    repositoryName = 'cert_task'
                    registryCredsID = 'AWS_ECR_CREDENTIALS'
                    registryHost = '657846606580.dkr.ecr.eu-central-1.amazonaws.com'
                }
            }
        }

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
               sh 'terraform destroy --auto-approve'
               script {
                   builderDnsName = ''
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
               sh "[ '${builderDnsName}' = '' ] || echo ${builderDnsName} >> hosts"
            }
        } // stage Ansible inventory prepare

        stage('Ansible playbook') {
            steps {
                ansiblePlaybook(
                    playbook: 'prepare-instances.yml',
                    inventory: 'hosts',
                    credentialsId: "${sshCredsID}",
                    disableHostKeyChecking: true,
                    become: true,
                )
            }
        } // stage Ansible

        stage('Builder fetch, build, push') {
            when {
                not {
                    equals( expected: '', actual: "${builderDnsName}" )
                }
            }

            steps {
                git branch: "application",
                    url: "https://github.com/LovingFox/devops-cert_task.git"
                sshagent( credentials:["${sshCredsID}"] ) {
                    withEnv (["DOCKER_HOST=ssh://${builderDnsName}"]) {
                        sh "docker build --build-arg APPVERSION=${params.appVersion} --tag ${registryHost}/${repositoryName}:${params.appVersion} ."
                        withDockerRegistry( [credentialsId:"${registryCredsID}", url:"https://${registryHost}"] ) {
                            sh "docker push ${registryHost}/${repositoryName}:${params.appVersion}"
                        }
                    }
                }
            }
        } // stage Builder fetch, build, push

    } // stages
}
