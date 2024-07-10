kubectl delete configmap pingfederate-data
kubectl delete secret pingfederate-jwk

kubectl create configmap pingfederate-data --from-file=data.json
kubectl create secret generic pingfederate-jwk --from-file=pf.jwk