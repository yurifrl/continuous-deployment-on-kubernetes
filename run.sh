#!/bin/bash

gcloud container clusters create jenkins-cd \
  --num-nodes 3 \
  --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"

# gcloud compute images create jenkins-home-image --source-uri https://storage.googleapis.com/solutions-public-assets/jenkins-cd/jenkins-home-v2.tar.gz
# gcloud compute disks create jenkins-home --image jenkins-home-image

gcloud container clusters get-credentials jenkins-cd
kubectl create ns jenkins
kubectl create -f ./object-counts.yaml --namespace=jenkins --validate=false
kubectl create -f ./compute-resources.yaml --namespace=jenkins --validate=false

kubectl create secret generic jenkins --from-file=jenkins/k8s/options --namespace=jenkins
kubectl apply -f jenkins/k8s/
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=jenkins/O=jenkins"
kubectl create secret generic tls --from-file=/tmp/tls.crt --from-file=/tmp/tls.key --namespace jenkins
kubectl apply -f jenkins/k8s/lb

kubectl get ingress --namespace jenkins
kubectl get pods --namespace jenkins
kubectl get svc --namespace jenkins
kubectl describe ingress jenkins --namespace jenkins
