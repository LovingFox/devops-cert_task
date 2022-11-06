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

    stage('Checkout') {
        steps {
            checkout scm, branches: [[name: '*/terraform']]
        }
    }

    stage('Plan') {
        when {
            not {
                equals expected: true, actual: params.destroy
            }
        }

        steps {
            sh 'terraform init -input=false'
            sh "terraform plan -input=false -out tfplan"
            sh 'terraform show -no-color tfplan > tfplan.txt'
        }
    }
}
