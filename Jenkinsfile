pipeline {
    agent {
        node {
            label 'master'
        }
    }
environment {
        ARM_ACCESS_KEY = 'true'
	ARM_CLIENT_ID = 'true'
	ARM_CLIENT_SECRET = 'true'
	ARM_SUBSCRIPTION_ID = 'true'
	ARM_TENANT_ID = 'true'
    }
    stages {
        stage('terraform start') {
            steps {
              echo env.ARM_ACCESS_KEY
	      echo env.ARM_CLIENT_ID
              echo env.ARM_CLIENT_SECRET
	      echo env.ARM_SUBSCRIPTION_ID
	      echo env.ARM_TENANT_ID
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
        stage('terraform plan') {
            steps {
                sh '''cd /var/lib/jenkins/workspace/Terraform/ && terraform plan -var 'vm_name=testvm2' -lock=false'''
                  }
                }
	stage('terraform apply') {
            steps {
                sh '''cd /var/lib/jenkins/workspace/Terraform/ && terraform apply -auto-approve -var 'vm_name=testvm2' -lock=false'''
                  }
                }
        stage('end') {
            steps {
                sh 'echo "Ended"'

	    }
        }
    }
}
