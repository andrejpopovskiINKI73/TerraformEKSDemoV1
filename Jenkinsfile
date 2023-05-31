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
                            powershell "terraform output -raw kubeconfig > C:/Users/andrej.popovski/.kube/AWSconfig"
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
                                    kubeconfig(caCertificate: '''LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1EVXp
                                    NVEV4TkRjek9Wb1hEVE16TURVeU9ERXhORGN6T1Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTnRLCjRuU3
                                    RxQlV6MlBTNnh3dERGcmxwQ1k1Ni9sMUdKTnFoYVNZYjA3ZTgxYVRERlF3cklnRFRXMDVybGMyY0x1SWMKOWRtckFPZ1g2L3JRUlRsRTJ4TkozTlN6eEhaVTdLNHZuODMrUm1ZRVExaVhoREE2NnVJb
                                    29vdCt3bEJ4bWhFSwpBMFBQSnBrbE1xM01WeFVIZmxQRHd6d3NHSXZRWUpwOW1GZkgydHlKUXZ2UElyVlpTRFhCNS9RUmwvK1gxSTJ0ClJmRGF0d0NpUHE2UW5HWjJFVnNSOFNiZWNrWVdSdmtoN0tR
                                    RDEyVDBXUjVVUVlvWngrLzJ6aXd2a21JS3ZrYXMKTWlEMmNXSGcwRHRrN25JT3hRZ2NWT2h0QUJSc0t3UjNxc3BqMGJVNlFSQ0QrZFB6NjEvcmRXSTAzMEJoY3BUbgplMHVzY3lFZGdDeSs5a1ZEOHo
                                    wQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZLVTRBWFJJRmtlZFRFYVNRZUR4YnFsd1dpOHdNQlVHQTFVZEVRUU8KTU
                                    F5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBRE5ML1RTVmJNZG1mZW53ck5TNgo2ZGRhRy8xS0xxZTlSRGlmRlZXMGFsMHUyTDFjQkN1Z2pVcGU0bW56elRVL2UxcmhWU
                                    lJaa2p6N0VXWDBkc0M1CmxQSGJrUUdTajhlblAxd1lPNUJaT25OYmt2a1NDalhIc2pMQTY0QkxWbHJXajkvMDl6L1hFOHptanFjNG1pUFUKTG1pWVhZZUNSREhpSjh6N0lFQ1ZaN3VlYzBlcUpHYmhI
                                    cFpGSTJhNTAyYmxGVzlwcld0QUhNVGg5V3Q0L1o5YgpwSmtVN1VYRUUxLyt4UUdNS25zd3I3aVRtVHp6SWMzc3ZpWS9SeTFrTjJSQ2c5Vlc4N2xwOXBOeEJhUzhMdldYCkpGZnZVV3dRMlc5YTliOCs
                                    0S0FuR3NmYTBscU5LK3pUTmQycVNDeTNFYzZtSkd5V29tZ1l0bk1lSlNvU09aakMKMnVjPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==''', credentialsId: 'AWSEKSCredentials', serverUrl: 'https://F9344790B436F4FC48A987CA9C739E4E.gr7.us-east-1.eks.amazonaws.com') {
                                        powershell 'kubectl apply -f sa-webapp.yaml --context aws'
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
                                        kubeconfig(caCertificate: '''LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1EVXp
                                        NVEV4TkRjek9Wb1hEVE16TURVeU9ERXhORGN6T1Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTnRLCjRuU3
                                        RxQlV6MlBTNnh3dERGcmxwQ1k1Ni9sMUdKTnFoYVNZYjA3ZTgxYVRERlF3cklnRFRXMDVybGMyY0x1SWMKOWRtckFPZ1g2L3JRUlRsRTJ4TkozTlN6eEhaVTdLNHZuODMrUm1ZRVExaVhoREE2NnVJb
                                        29vdCt3bEJ4bWhFSwpBMFBQSnBrbE1xM01WeFVIZmxQRHd6d3NHSXZRWUpwOW1GZkgydHlKUXZ2UElyVlpTRFhCNS9RUmwvK1gxSTJ0ClJmRGF0d0NpUHE2UW5HWjJFVnNSOFNiZWNrWVdSdmtoN0tR
                                        RDEyVDBXUjVVUVlvWngrLzJ6aXd2a21JS3ZrYXMKTWlEMmNXSGcwRHRrN25JT3hRZ2NWT2h0QUJSc0t3UjNxc3BqMGJVNlFSQ0QrZFB6NjEvcmRXSTAzMEJoY3BUbgplMHVzY3lFZGdDeSs5a1ZEOHo
                                        wQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZLVTRBWFJJRmtlZFRFYVNRZUR4YnFsd1dpOHdNQlVHQTFVZEVRUU8KTU
                                        F5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBRE5ML1RTVmJNZG1mZW53ck5TNgo2ZGRhRy8xS0xxZTlSRGlmRlZXMGFsMHUyTDFjQkN1Z2pVcGU0bW56elRVL2UxcmhWU
                                        lJaa2p6N0VXWDBkc0M1CmxQSGJrUUdTajhlblAxd1lPNUJaT25OYmt2a1NDalhIc2pMQTY0QkxWbHJXajkvMDl6L1hFOHptanFjNG1pUFUKTG1pWVhZZUNSREhpSjh6N0lFQ1ZaN3VlYzBlcUpHYmhI
                                        cFpGSTJhNTAyYmxGVzlwcld0QUhNVGg5V3Q0L1o5YgpwSmtVN1VYRUUxLyt4UUdNS25zd3I3aVRtVHp6SWMzc3ZpWS9SeTFrTjJSQ2c5Vlc4N2xwOXBOeEJhUzhMdldYCkpGZnZVV3dRMlc5YTliOCs
                                        0S0FuR3NmYTBscU5LK3pUTmQycVNDeTNFYzZtSkd5V29tZ1l0bk1lSlNvU09aakMKMnVjPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==''', credentialsId: 'AWSEKSCredentials', serverUrl: 'https://F9344790B436F4FC48A987CA9C739E4E.gr7.us-east-1.eks.amazonaws.com') {
                                            def output1 = powershell(script: '(kubectl cluster-info --context aws | Select-String -Pattern \'[0-9]{1,3}(\\.[0-9]{1,3}){3}\').Matches.Value | Select-Object -First 1', returnStdout: true).trim()
                                           
                                            def output2 = powershell(script: '$a = kubectl get service sa-web-app-lb --context aws -o json | ConvertFrom-Json; $a.spec.ports.nodePort', returnStdout: true).trim()

                                            def finalRes = "window.API_URL = 'http://${output1}:${output2}/sentiment'"
                                            
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

                                        //     def output1 = powershell(script: '(kubectl cluster-info | Select-String -Pattern \'[0-9]{1,3}(\\.[0-9]{1,3}){3}\').Matches.Value | Select-Object -First 1', returnStdout: true).trim()
                                           
                                        //     def output2 = powershell(script: '$a = kubectl get service sa-web-app-lb -o json | ConvertFrom-Json; $a.spec.ports.nodePort', returnStdout: true).trim()

                                        //     def finalRes = "window.API_URL = 'http://${output1}:${output2}/sentiment'"
                                            
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
                                    kubeconfig(caCertificate: '''LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1EVXp
                                    NVEV4TkRjek9Wb1hEVE16TURVeU9ERXhORGN6T1Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTnRLCjRuU3
                                    RxQlV6MlBTNnh3dERGcmxwQ1k1Ni9sMUdKTnFoYVNZYjA3ZTgxYVRERlF3cklnRFRXMDVybGMyY0x1SWMKOWRtckFPZ1g2L3JRUlRsRTJ4TkozTlN6eEhaVTdLNHZuODMrUm1ZRVExaVhoREE2NnVJb
                                    29vdCt3bEJ4bWhFSwpBMFBQSnBrbE1xM01WeFVIZmxQRHd6d3NHSXZRWUpwOW1GZkgydHlKUXZ2UElyVlpTRFhCNS9RUmwvK1gxSTJ0ClJmRGF0d0NpUHE2UW5HWjJFVnNSOFNiZWNrWVdSdmtoN0tR
                                    RDEyVDBXUjVVUVlvWngrLzJ6aXd2a21JS3ZrYXMKTWlEMmNXSGcwRHRrN25JT3hRZ2NWT2h0QUJSc0t3UjNxc3BqMGJVNlFSQ0QrZFB6NjEvcmRXSTAzMEJoY3BUbgplMHVzY3lFZGdDeSs5a1ZEOHo
                                    wQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZLVTRBWFJJRmtlZFRFYVNRZUR4YnFsd1dpOHdNQlVHQTFVZEVRUU8KTU
                                    F5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBRE5ML1RTVmJNZG1mZW53ck5TNgo2ZGRhRy8xS0xxZTlSRGlmRlZXMGFsMHUyTDFjQkN1Z2pVcGU0bW56elRVL2UxcmhWU
                                    lJaa2p6N0VXWDBkc0M1CmxQSGJrUUdTajhlblAxd1lPNUJaT25OYmt2a1NDalhIc2pMQTY0QkxWbHJXajkvMDl6L1hFOHptanFjNG1pUFUKTG1pWVhZZUNSREhpSjh6N0lFQ1ZaN3VlYzBlcUpHYmhI
                                    cFpGSTJhNTAyYmxGVzlwcld0QUhNVGg5V3Q0L1o5YgpwSmtVN1VYRUUxLyt4UUdNS25zd3I3aVRtVHp6SWMzc3ZpWS9SeTFrTjJSQ2c5Vlc4N2xwOXBOeEJhUzhMdldYCkpGZnZVV3dRMlc5YTliOCs
                                    0S0FuR3NmYTBscU5LK3pUTmQycVNDeTNFYzZtSkd5V29tZ1l0bk1lSlNvU09aakMKMnVjPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==''', credentialsId: 'AWSEKSCredentials', serverUrl: 'https://F9344790B436F4FC48A987CA9C739E4E.gr7.us-east-1.eks.amazonaws.com') {
                                        powershell 'kubectl apply -f sa-frontend.yaml --context aws'
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
                                    kubeconfig(caCertificate: '''LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1EVXp
                                    NVEV4TkRjek9Wb1hEVE16TURVeU9ERXhORGN6T1Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTnRLCjRuU3
                                    RxQlV6MlBTNnh3dERGcmxwQ1k1Ni9sMUdKTnFoYVNZYjA3ZTgxYVRERlF3cklnRFRXMDVybGMyY0x1SWMKOWRtckFPZ1g2L3JRUlRsRTJ4TkozTlN6eEhaVTdLNHZuODMrUm1ZRVExaVhoREE2NnVJb
                                    29vdCt3bEJ4bWhFSwpBMFBQSnBrbE1xM01WeFVIZmxQRHd6d3NHSXZRWUpwOW1GZkgydHlKUXZ2UElyVlpTRFhCNS9RUmwvK1gxSTJ0ClJmRGF0d0NpUHE2UW5HWjJFVnNSOFNiZWNrWVdSdmtoN0tR
                                    RDEyVDBXUjVVUVlvWngrLzJ6aXd2a21JS3ZrYXMKTWlEMmNXSGcwRHRrN25JT3hRZ2NWT2h0QUJSc0t3UjNxc3BqMGJVNlFSQ0QrZFB6NjEvcmRXSTAzMEJoY3BUbgplMHVzY3lFZGdDeSs5a1ZEOHo
                                    wQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZLVTRBWFJJRmtlZFRFYVNRZUR4YnFsd1dpOHdNQlVHQTFVZEVRUU8KTU
                                    F5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBRE5ML1RTVmJNZG1mZW53ck5TNgo2ZGRhRy8xS0xxZTlSRGlmRlZXMGFsMHUyTDFjQkN1Z2pVcGU0bW56elRVL2UxcmhWU
                                    lJaa2p6N0VXWDBkc0M1CmxQSGJrUUdTajhlblAxd1lPNUJaT25OYmt2a1NDalhIc2pMQTY0QkxWbHJXajkvMDl6L1hFOHptanFjNG1pUFUKTG1pWVhZZUNSREhpSjh6N0lFQ1ZaN3VlYzBlcUpHYmhI
                                    cFpGSTJhNTAyYmxGVzlwcld0QUhNVGg5V3Q0L1o5YgpwSmtVN1VYRUUxLyt4UUdNS25zd3I3aVRtVHp6SWMzc3ZpWS9SeTFrTjJSQ2c5Vlc4N2xwOXBOeEJhUzhMdldYCkpGZnZVV3dRMlc5YTliOCs
                                    0S0FuR3NmYTBscU5LK3pUTmQycVNDeTNFYzZtSkd5V29tZ1l0bk1lSlNvU09aakMKMnVjPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==''', credentialsId: 'AWSEKSCredentials', serverUrl: 'https://F9344790B436F4FC48A987CA9C739E4E.gr7.us-east-1.eks.amazonaws.com') {
                                        powershell 'kubectl apply -f sa-logic.yaml --context aws '
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