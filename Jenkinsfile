pipeline {
    agent {
        node {
            label 'master'
        }
    }
environment {
             armaccesskey= credentials('armaccesskey')
             armaccesskey= credentials('armclientid')
	     armclientsecret=credentials('armclientsecret')
	     armsubscrid=credentials('armsubscrid')
	     armtenantid=credentials('armtenantid')
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
