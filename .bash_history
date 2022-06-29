export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")
export CLUSTER_NAME=central
export CLUSTER_ZONE=us-central1-b
export WORKLOAD_POOL=${PROJECT_ID}.svc.id.goog
export MESH_ID="proj-${PROJECT_NUMBER}"
gcloud projects get-iam-policy $PROJECT_ID     --flatten="bindings[].members"     --filter="bindings.members:user:$(gcloud config get-value core/account 2>/dev/null)"
gcloud config set compute/zone ${CLUSTER_ZONE}
gcloud beta container clusters create ${CLUSTER_NAME}     --machine-type=n1-standard-4     --num-nodes=4     --workload-pool=${WORKLOAD_POOL}     --enable-stackdriver-kubernetes     --subnetwork=default     --release-channel=regular     --labels mesh_id=${MESH_ID}
kubectl create clusterrolebinding cluster-admin-binding   --clusterrole=cluster-admin   --user=$(whoami)@qwiklabs.net
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.12 > asmcli
chmod +x asmcli
clear
./asmcli validate   --project_id $PROJECT_ID   --cluster_name $CLUSTER_NAME   --cluster_location $CLUSTER_ZONE   --fleet_id $PROJECT_ID   --output_dir ./asm_output
./asmcli install   --project_id $PROJECT_ID   --cluster_name $CLUSTER_NAME   --cluster_location $CLUSTER_ZONE   --fleet_id $PROJECT_ID   --output_dir ./asm_output   --enable_all   --option legacy-default-ingressgateway   --ca mesh_ca   --enable_gcp_components
GATEWAY_NS=istio-gateway
kubectl create namespace $GATEWAY_NS
kubectl get deploy -n istio-system -l app=istiod -o jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}'
REVISION=$(kubectl get deploy -n istio-system -l app=istiod -o \
jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}')
kubectl label namespace $GATEWAY_NS istio.io/rev=$REVISION --overwrite
cd ~/asm_output
kubectl apply -n $GATEWAY_NS   -f samples/gateways/istio-ingressgateway
kubectl label namespace default istio-injection- istio.io/rev=$REVISION --overwrite
clear
cd istio-1.12.7-asm.2
cat samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
cat samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get services
kubectl get pods
kubectl exec -it $(kubectl get pod -l app=ratings \
    -o jsonpath='{.items[0].metadata.name}')     -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
kubectl get gateway
kubectl get svc istio-ingressgateway -n istio-system
export GATEWAY_URL=34.69.77.155
curl -I http://${GATEWAY_URL}/productpage
sudo apt install siege
siege http://${GATEWAY_URL}/productpage
ls
cd ..
ls
cd ..
ls
git init
