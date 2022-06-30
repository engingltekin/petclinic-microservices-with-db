echo 'Deploying App on Kubernetes'
envsubst < k8s/petclinic_chart/values-template.yaml > k8s/petclinic_chart/values.yaml
sed -i s/HELM_VERSION/${BUILD_NUMBER}/ k8s/petclinic_chart/Chart.yaml
AWS_REGION=$AWS_REGION helm repo add stable-petclinic s3://petclinic-helm-charts-engin/stablemyapp/ || echo "repository name already exists"
AWS_REGION=$AWS_REGION helm repo update
helm package k8s/petclinic_chart
AWS_REGION=$AWS_REGION helm s3 push --force petclinic_chart-${BUILD_NUMBER}.tgz stable-petclinic
envsubst < infrastructure/ansible/playbooks/qa-petclinic-deploy-template.yml >infrastructure/ansible/playbooks/qa-petclinic-deploy.yml
ansible-playbook -i ./infrastructure/ansible/inventory/qa_stack_dynamic_inventory_aws_ec2.yaml ./infrastructure/ansible/playbooks/qa-petclinic-deploy.yml