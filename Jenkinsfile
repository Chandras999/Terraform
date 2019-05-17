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
parameters {	
	string(name: 'vm_name',
	 description: 'Enter the desired VM Name')
}
    stages {

        stage('terraform init') {
            steps {
                sh '''
		cd $WORKSPACE/ && terraform init
		'''
            }
        }
     stage('plan') {
            steps {
                sh '''
		echo ${params.vm_name}
		#cd $WORKSPACE/ && terraform plan -var '${params.vm_name}' -lock=false
		'''
                  }
                }
     stage('terraform apply') {
            steps {
                
                sh '''
		#cd $WORKSPACE/ && terraform apply -auto-approve -var '${params.vm_name}' -lock=false
		'''
                  }
                }
        stage('terraform destroy') {
            steps {
                sh '''
		# cd /var/lib/jenkins/workspace/Terraform/ && terraform destroy -auto-approve -var '${params.vm_name}' -lock=false
		'''
                  }
                }
        stage('end') {
            steps {
                sh 'echo "Ended"'

	    }
        }
    }
}
