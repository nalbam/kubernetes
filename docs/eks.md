# EKS

```bash
export AWS_REGION="ap-northeast-2"
export CLUSTER_NAME="eks-demo"

curl -sL https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/${CLUSTER_NAME}/;s/{{region_name}}/${AWS_REGION}/" | kubectl apply -f -
```
