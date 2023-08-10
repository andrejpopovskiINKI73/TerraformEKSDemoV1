pipeline {
    agent any
    tools {
      terraform 'Terraform-1'
    }
    parameters{
            choice(
                choices:['plan','apply','destroy', 'skip'],
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
                checkout scmGit(branches: [[name: '*/Sa-AWS']], userRemoteConfigs: [[url: 'https://github.com/andrejpopovskiINKI73/TerraformEKSDemoV1.git']])
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
                            powershell "terraform output -raw kubeconfig > C:/Users/andrej.popovski/.kube/config"
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
                stage('Terraform skip'){
                     when {
                            expression{params.Actions == 'skip'}
                        }
                    steps{
                        dir('TerraformEKS') {
                            echo "Skipping AWS EKS step......."
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
                                dir('Sentiment-analyser-app/kubernetes-resources/'){
                                    powershell 'kubectl --kubeconfig=C:\\Users\\andrej.popovski\\.kube\\config apply -f sa-webapp.yaml'
                                    sleep(time: 20, unit: 'SECONDS')
                                }
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
                                    script{   
                                        def output1 = powershell(script: '$a = kubectl --kubeconfig=C:\\Users\\andrej.popovski\\.kube\\config describe svc sa-web-app-lb | Select-String -Pattern "LoadBalancer Ingress:" | ForEach-Object { $_.ToString().Split(\':\')[1].Trim() }; $b = $a.Trim(); $b', returnStdout: true).trim()
                                        def finalRes = "window.API_URL = 'http://${output1}/sentiment'"
                                        writeFile file: './public/config.js', text: finalRes
                                    }
                                    sleep(time: 15, unit: 'SECONDS')
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
                                        powershell 'kubectl --kubeconfig=C:\\Users\\andrej.popovski\\.kube\\config apply -f sa-frontend.yaml'
                                }
                                sleep(time: 30, unit: 'SECONDS')
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
                                    powershell 'kubectl --kubeconfig=C:\\Users\\andrej.popovski\\.kube\\config apply -f sa-logic.yaml'
                                }
                                sleep(time: 30, unit: 'SECONDS')
                            }
                        }
                    }
                }
                stage('Image build completion'){
                    steps{
                        echo "The images for the apps were built and pushed to dockerhub!"
                        echo "Deplyment to k8s was successful!"
                    }
                }
            }
        }
        stage('Finishing') {
            steps{
                script{
                    try{
                        def final1 = powershell(script: '$a = kubectl --kubeconfig=C:\\Users\\andrej.popovski\\.kube\\config describe svc sa-frontend-lb | Select-String -Pattern "LoadBalancer Ingress:" | ForEach-Object { $_.ToString().Split(\':\')[1].Trim() }; $b = $a.Trim(); $b', returnStdout: true).trim()
                        echo "Browse the frontend app on the following link:"
                        echo "link: ${final1}"
                    } catch (Exception e) {
                        echo "Link is unavailable, please check if the config files were applied correctly to the cluster"
                    }
                }
            }

        }
    }
    post {  
        always {
            echo 'Execution of the job was done'
        }  
        success {
            mail bcc: '', body: '''Pipeline finished successfully!!
        Regards,''', cc: '', from: '', replyTo: '', subject: 'SUCCESS', to: 'andrej.popovski.iw@gmail.com'
        }  
        failure {
            mail bcc: '', body: '''Pipeline failed, investigate issues!
        Regards,''', cc: '', from: '', replyTo: '', subject: 'Test', to: 'andrej.popovski.iw@gmail.com'
        }
    }
}