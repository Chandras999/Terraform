pipeline {
    agent {
        node {
            label 'master'
        }
    }
environment {
         ARM_ACCESS_KEY = credentials('ARM_ACCESS_KEY')
         ARM_CLIENT_ID = credentials('ARM_CLIENT_ID')
	     ARM_CLIENT_SECRET = credentials('ARM_CLIENT_SECRET')
	     ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
	     ARM_TENANT_ID = credentials('ARM_TENANT_ID')
    }
    stages {
        stage('terraform start') {
            steps {
              sh ' echo "started"'
            }
        }
        stage('git clone') {
            steps {
                sh 'sudo rm -rf Terraform* && sudo -n git clone https://github.com/Chandras999/Terraform.git'
            }
        }
        stage('terraform init') {
            steps {
                sh 'cd /var/lib/jenkins/workspace/Terraform/ && terraform init'
            }
        }
        stage('terraform destroy') {
            steps {
                sh '''cd /var/lib/jenkins/workspace/Terraform/ && terraform destroy -auto-approve -var 'vm_name=testvm2' -lock=false'''
                  }
                }
        stage('end') {
            steps {
                sh 'echo "Ended"'

	    }
        }
    }
}
