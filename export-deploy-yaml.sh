#!/usr/bin/env bash
# export k8s yaml files
# author: zhoulq
# creat time : 2024-9-6

if [ "$#" -ne 1 ]; then
    echo "Usage: ./export-deploy-yaml.sh <namespace>"
    exit 1
fi

namespaces=$1



export_deployment_yaml() {
    mkdir -p ./${namespaces}/deployment
    for dp in  $(kubectl get deployment   -n ${namespaces}  -o jsonpath='{.items..metadata.name}')
    do
        echo "exporting deployment $dp"
        kubectl get deployment $dp -n ${namespaces} -o yaml  | yq eval '
         del(
           .metadata.annotations,
           .metadata.creationTimestamp,
           .metadata.generation,
           .metadata.resourceVersion,
           .metadata.selfLink,
           .metadata.uid, 
           .metadata.managedFields,
           .spec.progressDeadlineSeconds,
           .spec.strategy,
           .spec.revisionHistoryLimit,
           .spec.template.metadata.creationTimestamp,
           .spec.template.metadata.annotations,
           .spec.template.spec.containers[].terminationMessagePath,
           .spec.template.spec.containers[].terminationMessagePolicy,
           .spec.template.spec.containers[].securityContext,
           .status
           )
       ' > ./${namespaces}/deployment/$dp.yaml
    done
    echo "========================================================="
}

export_service_yaml() {
    mkdir -p ./${namespaces}/service
    for svc in  $(kubectl get service  -n ${namespaces}  -o jsonpath='{.items..metadata.name}')
    do
        echo "exporting service $svc"
        kubectl get service $svc -n ${namespaces} -o yaml | yq eval '
         del(
           .metadata.annotations,
           .metadata.creationTimestamp,
           .metadata.resourceVersion,
           .metadata.selfLink,
           .metadata.uid, 
           .metadata.ownerReferences,
           .metadata.managedFields,
           .spec.clusterIPs,
           .spec.clusterIP,
           .spec.externalTrafficPolicy,
           .status
           )
       ' > ./${namespaces}/service/$svc.yaml
    done
    echo "========================================================="
}

export_ingress_yaml() {
    mkdir -p ./${namespaces}/ingress
    for ing in  $(kubectl get ingress  -n ${namespaces}  -o jsonpath='{.items..metadata.name}')
    do
        echo "exporting ingress $ing"
        kubectl get ingress $ing -n ${namespaces} -o yaml | yq eval '
          del(
            .metadata.annotations."kubectl.kubernetes.io/last-applied-configuration",
            .metadata.creationTimestamp,
            .metadata.finalizers,
            .metadata.generation,
            .metadata.resourceVersion,
            .metadata.selfLink,
            .metadata.uid,
            .metadata.managedFields,
            .metadata.annotations."field.cattle.io/publicEndpoints",
            .status
            )
        '  > ./${namespaces}/ingress/$ing.yaml
    done
    echo "========================================================="
}

export_configmap_yaml() {
    mkdir -p ./${namespaces}/configmap
    for cfg in  $(kubectl get configmap  -n ${namespaces}  -o jsonpath='{.items..metadata.name}')
    do
        echo "exporting configmap $cfg"
        kubectl get configmap $cfg -n ${namespaces} -o yaml | yq eval '
          del(
            .metadata.annotations,
            .metadata.creationTimestamp,
            .metadata.resourceVersion,
            .metadata.selfLink,
            .metadata.managedFields,
            .metadata.uid
            )
        ' > ./${namespaces}/configmap/$cfg.yaml
    done
    echo "========================================================="
}


export_secret_yaml() {
    mkdir -p ./${namespaces}/secret
    for sec in  $(kubectl get secret  -n ${namespaces}  -o jsonpath='{.items..metadata.name}')
    do
        echo "exporting secret $sec"
        kubectl get secret $sec -n ${namespaces} -o yaml | yq eval '
          del(
            .metadata.creationTimestamp,
            .metadata.resourceVersion,
            .metadata.selfLink,
            .metadata.annotations,
            .metadata.managedFields,
            .metadata.uid
            )
        '  > ./${namespaces}/secret/$sec.yaml
    done
    echo "========================================================="
}

export_deployment_yaml
export_configmap_yaml
export_secret_yaml
export_ingress_yaml
export_service_yaml

echo "========================================================="
echo "exporting done"
