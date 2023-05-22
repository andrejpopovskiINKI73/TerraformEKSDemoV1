#Requires -RunAsAdministrator

$env:test = minikube service sa-web-app-lb --url --profile minikube; "window.API_URL = '$env:test/sentiment'" > ./public/config.js