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
                checkout scmGit(branches: [[name: '*/terrActions']], extensions: [[$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [[path: '/TerraformEKS']]]], userRemoteConfigs: [[url: 'https://github.com/andrejpopovskiINKI73/TerraformEKSDemoV1.git']])
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
            stages{
                stage('Terraform plan'){
                     when {
                            expression{params.Actions == 'plan'}
                        }
                    steps{
                        dir('TerraformEKS') {
                            powershell "terraform ${params.Actions}"
                        }
                    }
                }
                stage('Terraform apply'){
                     when {
                            expression{params.Actions == 'apply'}
                        }
                    steps{
                        dir('TerraformEKS') {
                            powershell "terraform ${params.Actions} --auto-approve"
                            //replace the kube config file locally with the tf output, so we can execute kubectl commands locally for the cluster
                            powershell "terraform output -raw kubeconfig > $HOME/.kube/config"
                        }
                    }
                }
                stage('Terraform destroy'){
                     when {
                            expression{params.Actions == 'destroy'}
                        }
                    steps{
                        dir('TerraformEKS') {
                            powershell "terraform ${params.Actions} --auto-approve"
                        }
                    }
                }
            }
        }
        stage('Terraform end'){
            steps{
                echo "terraform ${params.Actions} was executed"
            }
        }
    }
}