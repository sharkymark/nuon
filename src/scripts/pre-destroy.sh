#!/bin/sh

set -u
set -e

echo "[pre-destroy] preparing to execute pre-destroy script"
role=`aws sts get-caller-identity | jq -r '.Arn'`

echo "[pre-destroy] region: "$AWS_REGION" role: "$role

echo "[pre-destroy] getting cluster credentials with aws eks update-kubeconfig"
aws eks update-kubeconfig --region $AWS_REGION --name $NUON_INSTALL_ID --alias $NUON_INSTALL_ID || exit 0

echo "[pre-destroy] deleting install namespace"
kubectl config set-context $NUON_INSTALL_ID
kubectl delete namespace $NUON_INSTALL_ID --ignore-not-found=true
