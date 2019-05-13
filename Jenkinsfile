pipeline {
    agent {
        node {
            label 'master'
        }
    }
env {
                env.ARM_ACCESS_KEY='/zrc1Zo4tldgDnT2nrJlro52d+9DMJurRrx/Np7nMzpzN4Qpcrn8ASWHgBdhzF0NBoyC35oeVYA59M9BKwXDNA=='
		env.export ARM_CLIENT_ID='89973d3c-c8d3-4dc8-aa96-d8231d6afdf1'
		env.export ARM_CLIENT_SECRET='2de25810-801c-4568-9c36-44af6f002ff8'
		env.export ARM_SUBSCRIPTION_ID='fd7d53ef-e290-4ab1-937e-fec061c00132'
		env.export ARM_TENANT_ID='7a32773c-a86e-490d-ae40-5780e4791a65'
    }
    stages {
        stage('terraform start') {
            steps {
              sh 'echo "Started"'
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
