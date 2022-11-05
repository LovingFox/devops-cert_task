pipeline {
    parameters {
        string(name: "appVersion", defaultValue: "1.0")
    }

    agent any

    stages {
        stage('Set vars') {
            steps {
                script {
                    dockerHost = "ssh://revyakin@95.73.61.76"
                    sshCredsID = "1d341349-b5bc-483f-9f54-151bcc426690"
                    regHost = "nexus.rtru.tk:8123"
                    regCredsID = "678de0e5-da9b-4305-bcf5-1f10f46f8246"
                }
            }
        }
        // stage('Get docker socket group') {
        //     steps {
        //         script {
        //             dockerGroup = sh(returnStdout: true, script: 'stat -c %g /var/run/docker.sock').trim()
        //         }
        //     }
        // }
        stage('Fetch, build, push') {
            agent {
                docker {
                    image "docker:20.10.21-git"
                    // args "--privileged -v /var/run/docker.sock:/var/run/docker.sock --group-add ${dockerGroup}"
                    args "--privileged -v /var/run/docker.sock:/var/run/docker.sock"
                    reuseNode true
                }
            }
            // environment {
            //     DOCKER_HOST="${dockerHost}"
            // }
            steps {
                sshagent (credentials: ["${sshCredsID}"]) {
                    git branch: "application",
                        url: "https://github.com/LovingFox/devops-cert_task.git"
                    withEnv (["DOCKER_HOST=${dockerHost}"]) {
                        sh "docker build --build-arg APPVERSION=${params.appVersion} --tag ${regHost}/cert_task:${params.appVersion} ."
                        withDockerRegistry([credentialsId: "${regCredsID}", url: "https://${regHost}/"]) {
                            sh "docker push ${regHost}/cert_task:${params.appVersion}"
                        }
                    }
                }
                // script {
                //     env.DOCKER_HOST = "ssh://revyakin@95.73.61.76"
                // }
                // sh "docker context update default --docker host=unix:///var/run/docker.sock"
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
