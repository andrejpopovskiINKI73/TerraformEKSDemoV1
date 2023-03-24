pipeline {
    agent any
    tools {
      terraform 'Terraform-1'
    }
    parameters{
            choice(
                choices:['plan','apply','destroy'],
                name:'Actions',
                description: 'Describes the Actions')
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
        stage('Validate'){
                steps{
                    dir('TerraformEKS') {
                        powershell 'terraform validate'
                    }
                }
            }
        stage('Terraform action'){
            steps{
                dir('TerraformEKS') {
                    powershell 'terraform ${params.Actions}'
                    //powershell 'terraform apply --auto-approve'
                }
                
            }
        }
        stage('Terraform end'){
            steps{
                echo 'terraform ${params.Actions} was executed'
            }
        }
    }
}