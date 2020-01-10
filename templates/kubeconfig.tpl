---
apiVersion: v1
clusters:
- cluster:
    server: ${endpoint}
    certificate-authority-data: ${ca_data}
  name: ${cluster_name}
contexts:
  - context:
      cluster: ${cluster_name}
      user: ${cluster_name}
    name: ${cluster_name}
current-context: ${cluster_name}
kind: Config
preferences: {}
users:
  - name: ${cluster_name}
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1alpha1
        env:
          - name: AWS_PROFILE
            value: ${aws_profile}
        command: aws
        args:
          - --region
          - ${cluster_region}
          - eks
          - get-token
          - --cluster-name
          - ${cluster_name}
          - "--role"
          - ${administrators_iam_role_arn}
