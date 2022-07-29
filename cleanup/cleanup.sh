#!/bin/bash

function GetPods() {
    shift
    local arr=("$@")
    if [[ $arr == "" ]]
    then  
        echo "No Pod Scheduled for Deletion"
    else
        for i in ${!arr[@]}; do
            echo -e "\nNo:  $i Pod:  ${arr[$i]} Namespace: $NAMESPACE"
            kubectl delete pods "${arr[$i]}" --force --grace-period=0 -n $NAMESPACE || echo "Unable to Delete."
        done 
    fi
}
export NAMESPACE=''
export a=$(kubectl get namespace | awk '{print $1}' | tail -n +2)
for i in $a; do echo "Namespace: $i" && export NAMESPACE=$i && podNames=$(kubectl get pods -n $NAMESPACE --sort-by=.metadata.creationTimestamp --field-selector status.phase=Failed -o go-template --template '{{range .items}}{{.metadata.name}} {{.metadata.creationTimestamp}}{{"\n"}}{{end}}' | awk '$2 <= "'$(date -Ins --utc | sed 's/+0000/Z/')'" { print $1 }') && podNames=($podNames) && echo $podNames && GetPods "${podNames[@]}"  && echo -e '\n\n' && podNames='';done