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
                                dir('Sentiment-analyser-app/kubernetes-resources/'){
                                    kubeconfig(caCertificate: '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
                                        a3ViZUNBMB4XDTIxMDkyODA4MjMzMloXDTMxMDkyNzA4MjMzMlowFTETMBEGA1UE
                                        AxMKbWluaWt1YmVDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN55
                                        p0MJVoZfSs1OaS+xY9YwBniB0Q0arwJQEPcbBkrzRjXbQ0cozqRCTYk8CIDl0KWF
                                        /rPZJTLd/U91+2yZPl4VfniOXJ7Qq0G43a9OPp/vfPFdoT0/aj9DSJmg6EBaf/2H
                                        gyNFwhm3pqyQhIJ5vQK5vMm8TRYVFU0ozbdorVVnVWgLsPpaHghtgc6jNnZlNV5Y
                                        xYRY9jQxtoOnMYOrOfTQ/jY2kAz/SA8hUOWGjQkw0JryYf5+8aO82ijpFT8du2jL
                                        3beq/QF0taCkDkDZ2aIi81iOstHouagf4TRhuQlUf2Kp1IwC4lsAprppGzCqkJmd
                                        akXHsIUing3GVD6KEecCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgKkMB0GA1UdJQQW
                                        MBQGCCsGAQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW
                                        BBRGe29aAjsTHNNDwlyJvzFr9w7mvzANBgkqhkiG9w0BAQsFAAOCAQEA2s+erSYh
                                        gevO7nEHLKTMICd3x9hb3BvLDy+eefwaCFBUzdXw4JM2f3eghKuoIFefuzjhH5nX
                                        ixb52H/ptcrwKqQTj9haoVrxGENre9/oaq8Vyj4WF6qp7UGAXMXQw2yfGjWFgC0o
                                        8sfE9pn+nfzI5kKTukl6XgHPxxTHYTJGOtncBKE33mswaY/bOcfZnInBJSs+exnb
                                        t2tarPt3yNLF9NcxaPrZARNyB2+FGfUAubAAjkIXy60W0+GSQ0IxELHgDYOCGUyx
                                        eM+bsDj072uqmtbClBGopsJfHw5nPXqVltd5QPzoBdcHpCAM2wHJgn7VAeXYD2ng
                                        AhfAq7oBiLn5Eg==''', credentialsId: 'mykubeconfig', serverUrl: 'https://172.25.152.242:8443') {
                                            powershell 'kubectl apply -f sa-webapp.yaml'
                                        }
                                    sleep(time: 60, unit: 'SECONDS')
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
                                        kubeconfig(caCertificate: '''MIID3DCCAsSgAwIBAgIBAjANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
                                        a3ViZUNBMB4XDTIzMDUxODExMDc1MloXDTI2MDUxODExMDc1MlowLDEXMBUGA1UE
                                        ChMOc3lzdGVtOm1hc3RlcnMxETAPBgNVBAMTCG1pbmlrdWJlMIIBIjANBgkqhkiG
                                        9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxPlLLmexdLZcDdoyPjuaX4Km1H98JBoJFTS6
                                        aPkW7wrIb2sDyvqeql6Ok7BdgXJMFKkQZ/BYF7eFHcuZ9q0OfrApQqHvsVBlhVrS
                                        UmVwXt1H9O57aTqIoWeXACgN/4gGGVhE3dHg/WFYPWSYkSs7U/6VuNxXiPEqgU8I
                                        +Vw/zENO3KRu6i05z9eGApxd1yKYVbsAstVZ7hX+6skh1xoY5yVaN0LFZD2wTdhO
                                        BsPMNfBZoN21qaVrzD66r8bt12vSs9v5Lq9d1epCv4BDgkEi4qTEs5eahRiFbYA4
                                        42gJADRZCGkyPz2ZXxqTsWV3duFEcm78sTKiMxdm5a2KGwLWgwIDAQABo4IBHjCC
                                        ARowDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcD
                                        AjAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFEZ7b1oCOxMc00PCXIm/MWv3Dua/
                                        MIG5BgNVHREEgbEwga6CCm1pbmlrdWJlQ0GCH2NvbnRyb2wtcGxhbmUubWluaWt1
                                        YmUuaW50ZXJuYWyCJGt1YmVybmV0ZXMuZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2Nh
                                        bIIWa3ViZXJuZXRlcy5kZWZhdWx0LnN2Y4ISa3ViZXJuZXRlcy5kZWZhdWx0ggpr
                                        dWJlcm5ldGVzgglsb2NhbGhvc3SHBKwZmPKHBApgAAGHBH8AAAGHBAoAAAEwDQYJ
                                        KoZIhvcNAQELBQADggEBAMhWGhJNcw8sCYSERRSD2/Olxjmy3xNb159V9OtZ2g9p
                                        Y4tE5TVfyT5acE0c/dQA2Dxiu90ie7KsBgFEtJuycEaxL7vZ/Nyozl9uq9JjdqkM
                                        tETF+RxwIdSAF8nwhuQ5KexktTQDHzgdU0Szi9pivS+lTthJy8KtgWA64UJ4a7t7
                                        2k1ZLW2PJLPDjFIWVvktsnOFG6eTzKg9+eZE6QixTC1QJ6H4pZQunwIS519HQhE7
                                        iWCjh4Y7/6d58ayv9LYvxzRjjomI18sHfD5kh8RWiVGZnZG34NiuLS8SU4sR5EDt
                                        HrM47YYO2xEsuTJ7dQO1oQjXzPX/WDPBCxkJTMxULis=''', credentialsId: 'mykubeconfig', serverUrl: 'https://172.25.152.242:8443') {
                                            env.MENDE = powershell 'minikube service sa-web-app-lb --url --profile minikube'
                                        }
                                        //env.MENDE = powershell 'minikube service sa-web-app-lb --url --profile minikube'
                                        env.PECE = 'window.API_URL = ${env.MENDE}'
                                        powershell '${env.PECE} > ./public/config.js'
                                    }
                                    //powershell '$env:test = minikube service sa-web-app-lb --url --profile minikube; "window.API_URL = \\\'$env:test/sentiment\\\'" > ./public/config.js'
                                    //powershell 'minikube service sa-web-app-lb --url --profile minikube'
                                    sleep(time: 30, unit: 'SECONDS')
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
                                    kubeconfig(caCertificate: '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
                                        a3ViZUNBMB4XDTIxMDkyODA4MjMzMloXDTMxMDkyNzA4MjMzMlowFTETMBEGA1UE
                                        AxMKbWluaWt1YmVDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN55
                                        p0MJVoZfSs1OaS+xY9YwBniB0Q0arwJQEPcbBkrzRjXbQ0cozqRCTYk8CIDl0KWF
                                        /rPZJTLd/U91+2yZPl4VfniOXJ7Qq0G43a9OPp/vfPFdoT0/aj9DSJmg6EBaf/2H
                                        gyNFwhm3pqyQhIJ5vQK5vMm8TRYVFU0ozbdorVVnVWgLsPpaHghtgc6jNnZlNV5Y
                                        xYRY9jQxtoOnMYOrOfTQ/jY2kAz/SA8hUOWGjQkw0JryYf5+8aO82ijpFT8du2jL
                                        3beq/QF0taCkDkDZ2aIi81iOstHouagf4TRhuQlUf2Kp1IwC4lsAprppGzCqkJmd
                                        akXHsIUing3GVD6KEecCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgKkMB0GA1UdJQQW
                                        MBQGCCsGAQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW
                                        BBRGe29aAjsTHNNDwlyJvzFr9w7mvzANBgkqhkiG9w0BAQsFAAOCAQEA2s+erSYh
                                        gevO7nEHLKTMICd3x9hb3BvLDy+eefwaCFBUzdXw4JM2f3eghKuoIFefuzjhH5nX
                                        ixb52H/ptcrwKqQTj9haoVrxGENre9/oaq8Vyj4WF6qp7UGAXMXQw2yfGjWFgC0o
                                        8sfE9pn+nfzI5kKTukl6XgHPxxTHYTJGOtncBKE33mswaY/bOcfZnInBJSs+exnb
                                        t2tarPt3yNLF9NcxaPrZARNyB2+FGfUAubAAjkIXy60W0+GSQ0IxELHgDYOCGUyx
                                        eM+bsDj072uqmtbClBGopsJfHw5nPXqVltd5QPzoBdcHpCAM2wHJgn7VAeXYD2ng
                                        AhfAq7oBiLn5Eg==''', credentialsId: 'mykubeconfig', serverUrl: 'https://172.25.152.242:8443') {
                                            powershell 'kubectl apply -f sa-frontend.yaml'
                                        }
                                    sleep(time: 60, unit: 'SECONDS')
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
                                    kubeconfig(caCertificate: '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
                                        a3ViZUNBMB4XDTIxMDkyODA4MjMzMloXDTMxMDkyNzA4MjMzMlowFTETMBEGA1UE
                                        AxMKbWluaWt1YmVDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN55
                                        p0MJVoZfSs1OaS+xY9YwBniB0Q0arwJQEPcbBkrzRjXbQ0cozqRCTYk8CIDl0KWF
                                        /rPZJTLd/U91+2yZPl4VfniOXJ7Qq0G43a9OPp/vfPFdoT0/aj9DSJmg6EBaf/2H
                                        gyNFwhm3pqyQhIJ5vQK5vMm8TRYVFU0ozbdorVVnVWgLsPpaHghtgc6jNnZlNV5Y
                                        xYRY9jQxtoOnMYOrOfTQ/jY2kAz/SA8hUOWGjQkw0JryYf5+8aO82ijpFT8du2jL
                                        3beq/QF0taCkDkDZ2aIi81iOstHouagf4TRhuQlUf2Kp1IwC4lsAprppGzCqkJmd
                                        akXHsIUing3GVD6KEecCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgKkMB0GA1UdJQQW
                                        MBQGCCsGAQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW
                                        BBRGe29aAjsTHNNDwlyJvzFr9w7mvzANBgkqhkiG9w0BAQsFAAOCAQEA2s+erSYh
                                        gevO7nEHLKTMICd3x9hb3BvLDy+eefwaCFBUzdXw4JM2f3eghKuoIFefuzjhH5nX
                                        ixb52H/ptcrwKqQTj9haoVrxGENre9/oaq8Vyj4WF6qp7UGAXMXQw2yfGjWFgC0o
                                        8sfE9pn+nfzI5kKTukl6XgHPxxTHYTJGOtncBKE33mswaY/bOcfZnInBJSs+exnb
                                        t2tarPt3yNLF9NcxaPrZARNyB2+FGfUAubAAjkIXy60W0+GSQ0IxELHgDYOCGUyx
                                        eM+bsDj072uqmtbClBGopsJfHw5nPXqVltd5QPzoBdcHpCAM2wHJgn7VAeXYD2ng
                                        AhfAq7oBiLn5Eg==''', credentialsId: 'mykubeconfig', serverUrl: 'https://172.25.152.242:8443') {
                                            powershell 'kubectl apply -f sa-logic.yaml'
                                        }
                                    sleep(time: 60, unit: 'SECONDS')
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