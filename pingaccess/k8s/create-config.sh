kubectl delete configmap pingaccess-data
kubectl delete secret pingaccess-jwk

kubectl create configmap pingaccess-data --from-file=data.json
kubectl create secret generic pingaccess-jwk --from-file=pa.jwk