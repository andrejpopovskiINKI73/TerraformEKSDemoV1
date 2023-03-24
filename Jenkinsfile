pipeline {
    agent any
    tools {
      terraform 'Terraform-1'
    }

    stages{
        stage('Git repo'){
            steps{
                checkout scmGit(branches: [[name: '*/localAWSProvider']], extensions: [[$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [[path: '/TerraformEKS']]]], userRemoteConfigs: [[url: 'https://github.com/andrejpopovskiINKI73/TerraformEKSDemoV1.git']])
            }
        }
        stage('Terraform init'){
            steps{
                dir('TerraformEKS') {
                    powershell 'terraform init'
                }
            }
        }
        stage('Terraform apply'){
            steps{
                dir('TerraformEKS') {
                    powershell 'terraform plan'
                    //sh 'terraform apply --auto-approve'
                }
                
            }
        }
    }
}