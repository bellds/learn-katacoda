#!/bin/bash
echo "Setting up Serverless..."

# Login as admin
oc login -u admin -u admin

# Apply the serverless operator
oc apply -f 01-prepare/operator-subscription.yaml

# Get serverless-operator.v.X.X... name
# Will be stored in "${BASH_REMATCH[0]}"
ops=`oc get csv -n openshift-operators`
pat='(serverless-operator\S+)'
[[ $ops =~ $pat ]] # From this line

echo "Serverless Operator Subscribed, waiting for deployment..."
# Setup waiting function
function wait_for_operator_install {
  local A=1
  local sub=$1
  while : ;
  do
    echo "$A: Checking..."
    phase=`oc get csv -n openshift-operators $sub -o jsonpath='{.status.phase}'`
    if [ $phase == "Succeeded" ]; then echo "$sub Installed"; break; fi
    A=$((A+1))
    sleep 10
  done
}

# Wait for...
wait_for_operator_install ${BASH_REMATCH[0]}

echo "Serverless Operator deployed. Deploying knative-serving..."
# If we make it this far we have deployed the Serverless Operator!
# Next, Knative Serving
oc apply -f 01-prepare/serving.yaml

# Wait for Serving to install
bash 01-prepare/watch-knative-serving.bash

echo "Serving deployed. Setting up developer env..."
# If we make it this far we are GOOD TO GO!
# Login as the developer and create a new project for our tutorial
oc login -u developer -p developer
oc new-project serverless-tutorial

# Done.
sleep 3
clear
echo "Serverless Tutorial Ready!"
