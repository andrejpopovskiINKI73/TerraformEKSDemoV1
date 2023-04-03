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
        stage('Sa-frontend'){
            stages{
                stage('npm build'){
                    steps{
                        dir('Sentiment-analyser-app/sa-frontend/'){
                            powershell "npm install"
                            powershell "npm run build"
                        }
                    }
                }
                stage('docker build'){
                    steps{
                        dir('Sentiment-analyser-app/sa-frontend/'){
                            powershell "docker build -f Dockerfile -t andrejpopovski123/sentiment-analysis-frontend ."
                        }
                    }
                }
                 stage('docker push'){
                    steps{
                        dir('Sentiment-analyser-app/sa-frontend/'){
                            withCredentials([string(credentialsId: 'dockerhubpwd', variable: 'dockerhubpwd')]) {
                                powershell "docker login --username andrejpopovski123 --password ${dockerhubpwd}"
                                powershell "docker push andrejpopovski123/sentiment-analysis-frontend"
                            }
                        }
                    }
                }
            }
        }
        stage('Sa-webapp'){
            stages{
                stage('java build'){
                    steps{
                        dir('Sentiment-analyser-app/sa-webapp/'){
                            powershell "mvn install"
                            //powershell "java -jar target/sentiment-analysis-web-0.0.1-SNAPSHOT.jar --sa.logic.api.url=http://localhost:5000"
                        }
                    }
                }
                stage('docker build'){
                    steps{
                        dir('Sentiment-analyser-app/sa-webapp/'){
                            powershell "docker build -f Dockerfile -t andrejpopovski123/sentiment-analysis-webapp ."
                        }
                    }
                }
                 stage('docker push'){
                    steps{
                        dir('Sentiment-analyser-app/sa-webapp/'){
                            withCredentials([string(credentialsId: 'dockerhubpwd', variable: 'dockerhubpwd')]) {
                                powershell "docker login --username andrejpopovski123 --password ${dockerhubpwd}"
                                powershell "docker push andrejpopovski123/sentiment-analysis-webapp"
                            }
                        }
                    }
                }
            }
        }
        stage('Sa-logic'){
            stages{
                stage('python pip install'){
                    steps{
                        dir('Sentiment-analyser-app/sa-logic/sa'){
                            powershell "python -m pip install -r requirements.txt"
                            powershell "python -m textblob.download_corpora"
                        }
                    }
                }
                stage('docker build'){
                    steps{
                        dir('Sentiment-analyser-app/sa-logic/'){
                            powershell "docker build -f Dockerfile -t andrejpopovski123/sentiment-analysis-logic ."
                        }
                    }
                }
                stage('docker push'){
                    steps{
                        dir('Sentiment-analyser-app/sa-logic/'){
                            withCredentials([string(credentialsId: 'dockerhubpwd', variable: 'dockerhubpwd')]) {
                                powershell "docker login --username andrejpopovski123 --password ${dockerhubpwd}"
                                powershell "docker push andrejpopovski123/sentiment-analysis-logic"
                            }
                        }
                    }
                }
            }
        }
        stage('Image build complition'){
            steps{
                powershell "echo The images for the apps were built and pushed to dockerhub!"
            }
        }
    }
}