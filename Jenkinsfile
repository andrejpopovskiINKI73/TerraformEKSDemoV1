pipeline {
    agent any
    tools {
      terraform 'Terraform-1'
    }
    parameters{
            choice(
                choices:['plan','apply','destroy'],
                name:'Actions',
                description: 'Describes the Actions'
            )
            booleanParam(
                defaultValue: false, 
                description: 'Select this if you want to build NEW docker images.', 
                name: 'BuildDockerImages'
            )
    }
    stages{
        stage('Git repo'){
            steps{
                checkout scmGit(branches: [[name: '*/dev']], userRemoteConfigs: [[url: 'https://github.com/andrejpopovskiINKI73/TerraformEKSDemoV1.git']])
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
        stage('Building apps docker images'){
            when {
                expression {env.BuildDockerImages == 'true'}
            }
            stages {
                stage('Sa-webapp'){
                    stages{
                        stage('java build'){
                            steps{
                                dir('Sentiment-analyser-app/sa-webapp/'){
                                    powershell "mvn install"
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
                        stage('webapp to k8s deploy'){
                            steps{
                                kubeconfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1ETXlPREF4TkRFd05sb1hEVE16TURNeU5UQXhOREV3Tmxvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBS01GClUwcmFmV3l0VzVqQXNlbHpET2t4M21UWHJ2bzRJVGk3dXo4QjJEV25wR2h3OEpMd2hxTTUyaW5uRFg2dkhYbmwKNC96L1hNRXdxNUkxQTRiYmh1blhpaVcrRFJGMHZKY3ppZGVYWjA4enhZdUFlTUZpZDlubElUaDhwUHhxWi9nWgp1MmhUUGt4SDNNNzEyM0lwYmtLMERjdkt5ZUlFNzdJdUhRaUNibGI4eU53RW5BcnM1Z0JhbHlmSDZjMFpjODF5CnZlb3VteVJlL3BxaFBsRCtDdXlLMWdvdkM4MjVmSlVoK0FUNjV2V0FyRnYrUDVldFMwZEdvTmVUT0NIcVArMFoKaG82dy84WSt2OXVpYzhtSmNOS0FpY1dqa2xPUDRIYlVhVmZLNnZHZnVFb3pKM1RkcExsWVpkdmwyVWc5WXlOSAp4d25MOUJPZ1psd2FzWVBZWWZVQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZNYnZZR1JaRzFDMnBCUktmTFErK0Q3czJuRldNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBRFR4SEhURE1ITzgvM0xyeWEvaQpVYm5yT2hBUEZVaGl3ZFl3ZjhRNmlwZmJVWnVlOGt4ZTJJdnpENUZjdWlLUGRRblFTdG1PWEZLTDBrU1QwSEw2CjdjL1RVMGJpc0RyRnoxVWNDNVc2bmtwcGhoS0cyNFU5L2ZYU1kwQ2ZWWUZzcGkzaXRpS0ozTnR0Yzdhd2xOOW0KRDlvYzR6Z0NxMnc5LzhYQmp0QmhlMkdwNWlVb0hCc2lUZ1dYZ25oNmorZ1dCOCtwYlBnYlNBdk5lZnRDT2srSgpaVi9GRzRUOFA2dWNuTWJLSFhJNmJWaWE0UUJtb3pYUFpxV1M0UUliRHI1YkhGUmxVTnQrVk9DOUg4MlRHRjFWCjZVZEpSZ0lEV3F4aVhOcnhXNk9zdDdsc0RlL2puRkFITHVXNmlnN1ZaZ1YyNHJhcmE2eHFHNEczK2dBQllZVW0KZ3drPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==', credentialsId: 'mykubeconfig', serverUrl: '') {
                                    kubernetesDeploy(
                                    configs: 'sa-webapp.yaml',
                                    kubeconfigId: 'mykubeconfig',
                                    enableConfigSubstitution: true
                                    )
                                }
                                sleep(time: 60, unit: SECONDS)
                            }
                        }
                        
                        
                    }
                }
                stage('Sa-frontend'){
                    stages{
                        stage('npm build'){
                            steps{
                                dir('Sentiment-analyser-app/sa-frontend/'){
                                    powershell "npm install"
                                    //FOR NOW WE BUILD AND PUSH THE DOCKER IMAGE WITH THE WEBAPP URL WE GET FROM MINIKUBE, IT WILL NEED TO BE SETUP DIFFERENTLY FOR ON CLOUD
                                    powershell '$env:test = minikube service sa-web-app-lb --url ; "window.API_URL = \'$env:test/sentiment\'" > ./public/config.js'
                                    sleep(time: 30, unit: SECONDS)
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
                        stage('frontend to k8s deploy'){
                            steps{
                                dir('Sentiment-analyser-app/kubernetes-resources/'){
                                    kubernetesDeploy(
                                            configs: 'sa-frontend.yaml',
                                            kubeconfigId: 'mykubeconfig',
                                            enableConfigSubstitution: true
                                        )
                                    sleep(time: 60, unit: SECONDS)
                                }
                            }
                        }
                    }
                }
                stage('Sa-logic'){
                    stages{
                        stage('python pip install'){
                            steps{
                                dir('Sentiment-analyser-app/sa-logic/sa/'){
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
                        stage('logic to k8s deploy'){
                            steps{
                                dir('Sentiment-analyser-app/kubernetes-resources/'){
                                    kubernetesDeploy(
                                            configs: 'sa-logic.yaml',
                                            kubeconfigId: 'mykubeconfig',
                                            enableConfigSubstitution: true
                                        )
                                    sleep(time: 60, unit: SECONDS)
                                }
                            }
                        }
                    }
                }
                stage('Image build completion'){
                    steps{
                        powershell "echo The images for the apps were built and pushed to dockerhub!"
                        powershell "echo Deplyment to k8s was successful!"
                    }
                }
            }
        }
    }
}