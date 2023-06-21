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
                            //powershell 'echo "test" > C:/Users/andrej.popovski/.kube/AWSconfig'
                            //powershell "terraform ${params.Actions} --auto-approve"
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
                                    kubeconfig(caCertificate: '''LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXS
                                        mwKY201bGRHVnpNQjRYRFRJek1EWXlNVEl4TURNek4xb1hEVE16TURZeE9ESXhNRE16TjFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGd
                                        nRVBBRENDQVFvQ2dnRUJBTXJpCk12MFlYS2dGeEc5ZzNOOWJuOGdWQXRpc2cvVnkrZG5UMVlTOUQ2STg3SjdCdUFLUk5TeWJHbjVPMGZ1dldodWQKM0Ywc3I0aWgzck1SR2ozUnVCeXZhcTFXVWt4b
                                        mttd3pia0tSeklhbnEvMS9JY1NVRGtvWlRGWXN0b3JyZWsycwpPaFBJV20rWUtxK051aUFNaDlSNGlwelhSL0k2aWdXbjZvblBzM3Y0QTQ1MU51M015WklvNmpLeHhpckdncXZ0CndRRXo2Q0xseXF
                                        zT2hVdDYrSW5IYmU0UElVdHhHNTh6a3hZeVFGWGowSkRvaStSaVlJTXNEZmNrYXVLcDJ3Z1AKUWhDL01GRVBhZUFXRnloWlJ2YWpiTlNRS010SWJGZUpRWmF6ZVpZZFROcnhYRlB4QWpGVXEvUkx4V
                                        UorVU1nQgorZXJIbmRITDFPZFdPSXZpMHhzQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZKa1FzTFZHU2Zoc0dFUVl
                                        ac015QkN0TjIrWWVNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBQkZOclRPRVhiMW5USm5HaFhGUApjQkVrbkJvTmt4VVhkL2N3RHlBVkhTV
                                        0Z4ZmpNcElHdlBSaXJ5Yy85ZXhzNWQ2UHN3Y1BicEpFbHhPb3dPM1NMClRFTmdYN21uRGpmVXIya1U3bW51V0w3empjRjRhNnVWS3ZUb2FQVUlQclFjNlEzQVdtRnFUTzFIWjVKOWpsRWwKL0g1YWY
                                        wV2RTamxqRncwb3VlemV1ck16UWk5eDNrSFlKWC9HcE8vQnFWQ3d3VTdIbHI1OUtWYk9PYnl5c1NJZApzdXpWOWEwQlhWMTJyYzhhYlZmYTYwNzZvL3FjZmsyMWYvemd0UTNkK081THdGb2hkVGdha
                                        G9USGcvYXJUcHJPCm44QnJNUmJDRUdTYlZvaGFCYzZITi9wNGNNQmdZQnJqSGxFYmcyRU5mT04vOHhYbDgraTMxbW04SmI1VE5TSUQKY1BzPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==''', credentialsId: 'AWSEKSTry1', serverUrl: 'https://E8DE8FF6B53CABFCD7AC99D0632F9417.gr7.us-east-1.eks.amazonaws.com') {
                                        powershell 'kubectl apply -f sa-webapp.yaml'
                                    }
                                    // kubeconfig(caCertificate: '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
                                    // a3ViZUNBMB4XDTIxMDkyODA4MjMzMloXDTMxMDkyNzA4MjMzMlowFTETMBEGA1UE
                                    // AxMKbWluaWt1YmVDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN55
                                    // p0MJVoZfSs1OaS+xY9YwBniB0Q0arwJQEPcbBkrzRjXbQ0cozqRCTYk8CIDl0KWF
                                    // /rPZJTLd/U91+2yZPl4VfniOXJ7Qq0G43a9OPp/vfPFdoT0/aj9DSJmg6EBaf/2H
                                    // gyNFwhm3pqyQhIJ5vQK5vMm8TRYVFU0ozbdorVVnVWgLsPpaHghtgc6jNnZlNV5Y
                                    // xYRY9jQxtoOnMYOrOfTQ/jY2kAz/SA8hUOWGjQkw0JryYf5+8aO82ijpFT8du2jL
                                    // 3beq/QF0taCkDkDZ2aIi81iOstHouagf4TRhuQlUf2Kp1IwC4lsAprppGzCqkJmd
                                    // akXHsIUing3GVD6KEecCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgKkMB0GA1UdJQQW
                                    // MBQGCCsGAQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW
                                    // BBRGe29aAjsTHNNDwlyJvzFr9w7mvzANBgkqhkiG9w0BAQsFAAOCAQEA2s+erSYh
                                    // gevO7nEHLKTMICd3x9hb3BvLDy+eefwaCFBUzdXw4JM2f3eghKuoIFefuzjhH5nX
                                    // ixb52H/ptcrwKqQTj9haoVrxGENre9/oaq8Vyj4WF6qp7UGAXMXQw2yfGjWFgC0o
                                    // 8sfE9pn+nfzI5kKTukl6XgHPxxTHYTJGOtncBKE33mswaY/bOcfZnInBJSs+exnb
                                    // t2tarPt3yNLF9NcxaPrZARNyB2+FGfUAubAAjkIXy60W0+GSQ0IxELHgDYOCGUyx
                                    // eM+bsDj072uqmtbClBGopsJfHw5nPXqVltd5QPzoBdcHpCAM2wHJgn7VAeXYD2ng
                                    // AhfAq7oBiLn5Eg==''', credentialsId: 'minikubeee', serverUrl: 'https://172.20.31.172:8443') {
                                    //     powershell 'kubectl apply -f sa-webapp.yaml'
                                    // }
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
                                        kubeconfig(caCertificate: '''LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXS
                                        mwKY201bGRHVnpNQjRYRFRJek1EWXlNVEl4TURNek4xb1hEVE16TURZeE9ESXhNRE16TjFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGd
                                        nRVBBRENDQVFvQ2dnRUJBTXJpCk12MFlYS2dGeEc5ZzNOOWJuOGdWQXRpc2cvVnkrZG5UMVlTOUQ2STg3SjdCdUFLUk5TeWJHbjVPMGZ1dldodWQKM0Ywc3I0aWgzck1SR2ozUnVCeXZhcTFXVWt4b
                                        mttd3pia0tSeklhbnEvMS9JY1NVRGtvWlRGWXN0b3JyZWsycwpPaFBJV20rWUtxK051aUFNaDlSNGlwelhSL0k2aWdXbjZvblBzM3Y0QTQ1MU51M015WklvNmpLeHhpckdncXZ0CndRRXo2Q0xseXF
                                        zT2hVdDYrSW5IYmU0UElVdHhHNTh6a3hZeVFGWGowSkRvaStSaVlJTXNEZmNrYXVLcDJ3Z1AKUWhDL01GRVBhZUFXRnloWlJ2YWpiTlNRS010SWJGZUpRWmF6ZVpZZFROcnhYRlB4QWpGVXEvUkx4V
                                        UorVU1nQgorZXJIbmRITDFPZFdPSXZpMHhzQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZKa1FzTFZHU2Zoc0dFUVl
                                        ac015QkN0TjIrWWVNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBQkZOclRPRVhiMW5USm5HaFhGUApjQkVrbkJvTmt4VVhkL2N3RHlBVkhTV
                                        0Z4ZmpNcElHdlBSaXJ5Yy85ZXhzNWQ2UHN3Y1BicEpFbHhPb3dPM1NMClRFTmdYN21uRGpmVXIya1U3bW51V0w3empjRjRhNnVWS3ZUb2FQVUlQclFjNlEzQVdtRnFUTzFIWjVKOWpsRWwKL0g1YWY
                                        wV2RTamxqRncwb3VlemV1ck16UWk5eDNrSFlKWC9HcE8vQnFWQ3d3VTdIbHI1OUtWYk9PYnl5c1NJZApzdXpWOWEwQlhWMTJyYzhhYlZmYTYwNzZvL3FjZmsyMWYvemd0UTNkK081THdGb2hkVGdha
                                        G9USGcvYXJUcHJPCm44QnJNUmJDRUdTYlZvaGFCYzZITi9wNGNNQmdZQnJqSGxFYmcyRU5mT04vOHhYbDgraTMxbW04SmI1VE5TSUQKY1BzPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==''', credentialsId: 'AWSEKSTry1', serverUrl: 'https://E8DE8FF6B53CABFCD7AC99D0632F9417.gr7.us-east-1.eks.amazonaws.com') {
                                            def output1 = powershell 'kubectl describe svc sa-web-app-lb | Select-String -Pattern "LoadBalancer Ingress:" | ForEach-Object { $_.ToString().Split(\':\')[1].Trim() }'
                                           
                                            //def output2 = powershell(script: '$a = kubectl get service sa-web-app-lb --context aws -o json | ConvertFrom-Json; $a.spec.ports.nodePort', returnStdout: true).trim()

                                            //def finalRes = "window.API_URL = 'http://${output1}:${output2}/sentiment'"
                                            def finalRes = "window.API_URL = 'http://${output1}/sentiment'"

                                            echo "just printing the returned value: ${finalRes}"
                                            writeFile file: './public/config.js', text: finalRes
                                        }
                                        // kubeconfig(caCertificate: '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
                                        // a3ViZUNBMB4XDTIxMDkyODA4MjMzMloXDTMxMDkyNzA4MjMzMlowFTETMBEGA1UE
                                        // AxMKbWluaWt1YmVDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN55
                                        // p0MJVoZfSs1OaS+xY9YwBniB0Q0arwJQEPcbBkrzRjXbQ0cozqRCTYk8CIDl0KWF
                                        // /rPZJTLd/U91+2yZPl4VfniOXJ7Qq0G43a9OPp/vfPFdoT0/aj9DSJmg6EBaf/2H
                                        // gyNFwhm3pqyQhIJ5vQK5vMm8TRYVFU0ozbdorVVnVWgLsPpaHghtgc6jNnZlNV5Y
                                        // xYRY9jQxtoOnMYOrOfTQ/jY2kAz/SA8hUOWGjQkw0JryYf5+8aO82ijpFT8du2jL
                                        // 3beq/QF0taCkDkDZ2aIi81iOstHouagf4TRhuQlUf2Kp1IwC4lsAprppGzCqkJmd
                                        // akXHsIUing3GVD6KEecCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgKkMB0GA1UdJQQW
                                        // MBQGCCsGAQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW
                                        // BBRGe29aAjsTHNNDwlyJvzFr9w7mvzANBgkqhkiG9w0BAQsFAAOCAQEA2s+erSYh
                                        // gevO7nEHLKTMICd3x9hb3BvLDy+eefwaCFBUzdXw4JM2f3eghKuoIFefuzjhH5nX
                                        // ixb52H/ptcrwKqQTj9haoVrxGENre9/oaq8Vyj4WF6qp7UGAXMXQw2yfGjWFgC0o
                                        // 8sfE9pn+nfzI5kKTukl6XgHPxxTHYTJGOtncBKE33mswaY/bOcfZnInBJSs+exnb
                                        // t2tarPt3yNLF9NcxaPrZARNyB2+FGfUAubAAjkIXy60W0+GSQ0IxELHgDYOCGUyx
                                        // eM+bsDj072uqmtbClBGopsJfHw5nPXqVltd5QPzoBdcHpCAM2wHJgn7VAeXYD2ng
                                        // AhfAq7oBiLn5Eg==''', credentialsId: 'minikubeee', serverUrl: 'https://172.20.31.172:8443') {

                                        //     def output1 = powershell 'kubectl describe svc sa-web-app-lb | Select-String -Pattern "LoadBalancer Ingress:" | ForEach-Object { $_.ToString().Split(\':\')[1].Trim() }'
                                           
                                        //     def output2 = powershell(script: '$a = kubectl get service sa-web-app-lb -o json | ConvertFrom-Json; $a.spec.ports.nodePort', returnStdout: true).trim()

                                        //    def finalRes = "window.API_URL = 'http://${output1}:${output2}/sentiment'"
                                            
                                        //     echo "just printing the returned value: ${finalRes}"
                                        //     writeFile file: './public/config.js', text: finalRes
                                        // }
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
                                    kubeconfig(caCertificate: '''LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXS
                                        mwKY201bGRHVnpNQjRYRFRJek1EWXlNVEl4TURNek4xb1hEVE16TURZeE9ESXhNRE16TjFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGd
                                        nRVBBRENDQVFvQ2dnRUJBTXJpCk12MFlYS2dGeEc5ZzNOOWJuOGdWQXRpc2cvVnkrZG5UMVlTOUQ2STg3SjdCdUFLUk5TeWJHbjVPMGZ1dldodWQKM0Ywc3I0aWgzck1SR2ozUnVCeXZhcTFXVWt4b
                                        mttd3pia0tSeklhbnEvMS9JY1NVRGtvWlRGWXN0b3JyZWsycwpPaFBJV20rWUtxK051aUFNaDlSNGlwelhSL0k2aWdXbjZvblBzM3Y0QTQ1MU51M015WklvNmpLeHhpckdncXZ0CndRRXo2Q0xseXF
                                        zT2hVdDYrSW5IYmU0UElVdHhHNTh6a3hZeVFGWGowSkRvaStSaVlJTXNEZmNrYXVLcDJ3Z1AKUWhDL01GRVBhZUFXRnloWlJ2YWpiTlNRS010SWJGZUpRWmF6ZVpZZFROcnhYRlB4QWpGVXEvUkx4V
                                        UorVU1nQgorZXJIbmRITDFPZFdPSXZpMHhzQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZKa1FzTFZHU2Zoc0dFUVl
                                        ac015QkN0TjIrWWVNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBQkZOclRPRVhiMW5USm5HaFhGUApjQkVrbkJvTmt4VVhkL2N3RHlBVkhTV
                                        0Z4ZmpNcElHdlBSaXJ5Yy85ZXhzNWQ2UHN3Y1BicEpFbHhPb3dPM1NMClRFTmdYN21uRGpmVXIya1U3bW51V0w3empjRjRhNnVWS3ZUb2FQVUlQclFjNlEzQVdtRnFUTzFIWjVKOWpsRWwKL0g1YWY
                                        wV2RTamxqRncwb3VlemV1ck16UWk5eDNrSFlKWC9HcE8vQnFWQ3d3VTdIbHI1OUtWYk9PYnl5c1NJZApzdXpWOWEwQlhWMTJyYzhhYlZmYTYwNzZvL3FjZmsyMWYvemd0UTNkK081THdGb2hkVGdha
                                        G9USGcvYXJUcHJPCm44QnJNUmJDRUdTYlZvaGFCYzZITi9wNGNNQmdZQnJqSGxFYmcyRU5mT04vOHhYbDgraTMxbW04SmI1VE5TSUQKY1BzPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==''', credentialsId: 'AWSEKSTry1', serverUrl: 'https://E8DE8FF6B53CABFCD7AC99D0632F9417.gr7.us-east-1.eks.amazonaws.com') {
                                        powershell 'kubectl apply -f sa-frontend.yaml'
                                    }
                                    // kubeconfig(caCertificate: '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
                                    // a3ViZUNBMB4XDTIxMDkyODA4MjMzMloXDTMxMDkyNzA4MjMzMlowFTETMBEGA1UE
                                    // AxMKbWluaWt1YmVDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN55
                                    // p0MJVoZfSs1OaS+xY9YwBniB0Q0arwJQEPcbBkrzRjXbQ0cozqRCTYk8CIDl0KWF
                                    // /rPZJTLd/U91+2yZPl4VfniOXJ7Qq0G43a9OPp/vfPFdoT0/aj9DSJmg6EBaf/2H
                                    // gyNFwhm3pqyQhIJ5vQK5vMm8TRYVFU0ozbdorVVnVWgLsPpaHghtgc6jNnZlNV5Y
                                    // xYRY9jQxtoOnMYOrOfTQ/jY2kAz/SA8hUOWGjQkw0JryYf5+8aO82ijpFT8du2jL
                                    // 3beq/QF0taCkDkDZ2aIi81iOstHouagf4TRhuQlUf2Kp1IwC4lsAprppGzCqkJmd
                                    // akXHsIUing3GVD6KEecCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgKkMB0GA1UdJQQW
                                    // MBQGCCsGAQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW
                                    // BBRGe29aAjsTHNNDwlyJvzFr9w7mvzANBgkqhkiG9w0BAQsFAAOCAQEA2s+erSYh
                                    // gevO7nEHLKTMICd3x9hb3BvLDy+eefwaCFBUzdXw4JM2f3eghKuoIFefuzjhH5nX
                                    // ixb52H/ptcrwKqQTj9haoVrxGENre9/oaq8Vyj4WF6qp7UGAXMXQw2yfGjWFgC0o
                                    // 8sfE9pn+nfzI5kKTukl6XgHPxxTHYTJGOtncBKE33mswaY/bOcfZnInBJSs+exnb
                                    // t2tarPt3yNLF9NcxaPrZARNyB2+FGfUAubAAjkIXy60W0+GSQ0IxELHgDYOCGUyx
                                    // eM+bsDj072uqmtbClBGopsJfHw5nPXqVltd5QPzoBdcHpCAM2wHJgn7VAeXYD2ng
                                    // AhfAq7oBiLn5Eg==''', credentialsId: 'minikubeee', serverUrl: 'https://172.20.31.172:8443') {
                                    //     powershell 'kubectl apply -f sa-frontend.yaml'
                                    // }
                                    sleep(time: 30, unit: 'SECONDS')
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
                                    kubeconfig(caCertificate: '''LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXS
                                        mwKY201bGRHVnpNQjRYRFRJek1EWXlNVEl4TURNek4xb1hEVE16TURZeE9ESXhNRE16TjFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGd
                                        nRVBBRENDQVFvQ2dnRUJBTXJpCk12MFlYS2dGeEc5ZzNOOWJuOGdWQXRpc2cvVnkrZG5UMVlTOUQ2STg3SjdCdUFLUk5TeWJHbjVPMGZ1dldodWQKM0Ywc3I0aWgzck1SR2ozUnVCeXZhcTFXVWt4b
                                        mttd3pia0tSeklhbnEvMS9JY1NVRGtvWlRGWXN0b3JyZWsycwpPaFBJV20rWUtxK051aUFNaDlSNGlwelhSL0k2aWdXbjZvblBzM3Y0QTQ1MU51M015WklvNmpLeHhpckdncXZ0CndRRXo2Q0xseXF
                                        zT2hVdDYrSW5IYmU0UElVdHhHNTh6a3hZeVFGWGowSkRvaStSaVlJTXNEZmNrYXVLcDJ3Z1AKUWhDL01GRVBhZUFXRnloWlJ2YWpiTlNRS010SWJGZUpRWmF6ZVpZZFROcnhYRlB4QWpGVXEvUkx4V
                                        UorVU1nQgorZXJIbmRITDFPZFdPSXZpMHhzQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZKa1FzTFZHU2Zoc0dFUVl
                                        ac015QkN0TjIrWWVNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBQkZOclRPRVhiMW5USm5HaFhGUApjQkVrbkJvTmt4VVhkL2N3RHlBVkhTV
                                        0Z4ZmpNcElHdlBSaXJ5Yy85ZXhzNWQ2UHN3Y1BicEpFbHhPb3dPM1NMClRFTmdYN21uRGpmVXIya1U3bW51V0w3empjRjRhNnVWS3ZUb2FQVUlQclFjNlEzQVdtRnFUTzFIWjVKOWpsRWwKL0g1YWY
                                        wV2RTamxqRncwb3VlemV1ck16UWk5eDNrSFlKWC9HcE8vQnFWQ3d3VTdIbHI1OUtWYk9PYnl5c1NJZApzdXpWOWEwQlhWMTJyYzhhYlZmYTYwNzZvL3FjZmsyMWYvemd0UTNkK081THdGb2hkVGdha
                                        G9USGcvYXJUcHJPCm44QnJNUmJDRUdTYlZvaGFCYzZITi9wNGNNQmdZQnJqSGxFYmcyRU5mT04vOHhYbDgraTMxbW04SmI1VE5TSUQKY1BzPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==''', credentialsId: 'AWSEKSTry1', serverUrl: 'https://E8DE8FF6B53CABFCD7AC99D0632F9417.gr7.us-east-1.eks.amazonaws.com') {
                                        powershell 'kubectl apply -f sa-logic.yaml'
                                    }
                                    // kubeconfig(caCertificate: '''MIIDBjCCAe6gAwIBAgIBATANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwptaW5p
                                    // a3ViZUNBMB4XDTIxMDkyODA4MjMzMloXDTMxMDkyNzA4MjMzMlowFTETMBEGA1UE
                                    // AxMKbWluaWt1YmVDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN55
                                    // p0MJVoZfSs1OaS+xY9YwBniB0Q0arwJQEPcbBkrzRjXbQ0cozqRCTYk8CIDl0KWF
                                    // /rPZJTLd/U91+2yZPl4VfniOXJ7Qq0G43a9OPp/vfPFdoT0/aj9DSJmg6EBaf/2H
                                    // gyNFwhm3pqyQhIJ5vQK5vMm8TRYVFU0ozbdorVVnVWgLsPpaHghtgc6jNnZlNV5Y
                                    // xYRY9jQxtoOnMYOrOfTQ/jY2kAz/SA8hUOWGjQkw0JryYf5+8aO82ijpFT8du2jL
                                    // 3beq/QF0taCkDkDZ2aIi81iOstHouagf4TRhuQlUf2Kp1IwC4lsAprppGzCqkJmd
                                    // akXHsIUing3GVD6KEecCAwEAAaNhMF8wDgYDVR0PAQH/BAQDAgKkMB0GA1UdJQQW
                                    // MBQGCCsGAQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQW
                                    // BBRGe29aAjsTHNNDwlyJvzFr9w7mvzANBgkqhkiG9w0BAQsFAAOCAQEA2s+erSYh
                                    // gevO7nEHLKTMICd3x9hb3BvLDy+eefwaCFBUzdXw4JM2f3eghKuoIFefuzjhH5nX
                                    // ixb52H/ptcrwKqQTj9haoVrxGENre9/oaq8Vyj4WF6qp7UGAXMXQw2yfGjWFgC0o
                                    // 8sfE9pn+nfzI5kKTukl6XgHPxxTHYTJGOtncBKE33mswaY/bOcfZnInBJSs+exnb
                                    // t2tarPt3yNLF9NcxaPrZARNyB2+FGfUAubAAjkIXy60W0+GSQ0IxELHgDYOCGUyx
                                    // eM+bsDj072uqmtbClBGopsJfHw5nPXqVltd5QPzoBdcHpCAM2wHJgn7VAeXYD2ng
                                    // AhfAq7oBiLn5Eg==''', credentialsId: 'minikubeee', serverUrl: 'https://172.20.31.172:8443') {
                                    //     powershell 'kubectl apply -f sa-logic.yaml'
                                    // }
                                    sleep(time: 30, unit: 'SECONDS')
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