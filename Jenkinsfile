pipeline {
    agent {
        node {
            label 'master'
        }
    }
environment {
                ARM_ACCESS_KEY='/zrc1Zo4tldgDnT2nrJlro52d+9DMJurRrx/Np7nMzpzN4Qpcrn8ASWHgBdhzF0NBoyC35oeVYA59M9BKwXDNA=='
		ARM_CLIENT_ID='89973d3c-c8d3-4dc8-aa96-d8231d6afdf1'
		ARM_CLIENT_SECRET='2de25810-801c-4568-9c36-44af6f002ff8'
		ARM_SUBSCRIPTION_ID='fd7d53ef-e290-4ab1-937e-fec061c00132'
		ARM_TENANT_ID='7a32773c-a86e-490d-ae40-5780e4791a65'
    }
    stages {
        stage('terraform start') {
            steps {
              sh 'echo "Started"'
            }
        }
        stage('git clone') {
            steps {
                sh 'sudo -n git clone https://github.com/Chandras999/Terraform.git'
            }
        }
        stage('terraform init') {
            steps {
                sh '/var/lib/jenkins/workspace/Terraform/azureterraform/terraform init -backend=true -input=false'
            }
        }
        stage('plan') {
            steps {
                sh '''/var/lib/jenkins/workspace/Terraform/azureterraform/terraform plan -var 'vm_name=testvm2'-lock=false'''
                  }
                }
        stage('end') {
            steps {
                sh 'echo "Ended"'

}
        }
    }
}
