pipeline {
    parameters {
        string(name: "appVersion", defaultValue: "1.0")
    }

    agent any

    stages {
        stage('Set environments') {
            steps {
                script {
                    env.DOCKER_HOST = "ssh://revyakin@95.73.61.76"
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
        stage('Fetch and build') {
            agent {
                withCredentials(credentials: ['1d341349-b5bc-483f-9f54-151bcc426690']) {
                    docker {
                        image "docker:20.10.21-git"
                        // args "--privileged -v /var/run/docker.sock:/var/run/docker.sock --group-add ${dockerGroup}"
                        args "--privileged -v /var/run/docker.sock:/var/run/docker.sock"
                        reuseNode true
                    }
                }
            }
            steps {
                // sshagent (credentials: ['1d341349-b5bc-483f-9f54-151bcc426690']) {
                    git branch: "application",
                        url: "https://github.com/LovingFox/devops-cert_task.git"
                    // sh "docker context update default --docker host=unix:///var/run/docker.sock"
                    sh "docker build --build-arg APPVERSION=${params.appVersion} --tag nexus.rtru.tk:8123/cert_task:${params.appVersion} ."
                // }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
