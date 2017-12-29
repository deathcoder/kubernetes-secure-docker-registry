#!/bin/bash
set -e
set -o pipefail

mkdir certs

#get rid of any old certs; careful here, maybe require flag?
kubectl delete secret registry-cert || true
kubectl delete secret --namespace=docker-registry registry-cert || true
kubectl delete secret --namespace=docker-registry registry-key || true
kubectl delete secret --namespace=docker-registry ingress-registry-tls-secret || true

openssl req -config /in.req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 265 -out certs/ca.crt

cat /in.req
#put the public key in both the default and docker-registry namespaces
kubectl create secret generic registry-cert --from-file=./certs/ca.crt 
kubectl create --namespace=docker-registry secret generic registry-cert --from-file=./certs/ca.crt 
kubectl create --namespace=docker-registry secret generic registry-key --from-file=./certs/domain.key

kubectl --namespace=docker-registry create secret generic ingress-registry-tls-secret --from-file=tls.crt=./certs/ca.crt --from-file=tls.key=./certs/domain.key
