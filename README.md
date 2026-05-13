## Pre requisites

1. Have docker installed
2. Have Kind (Kubernetes for docker) installed

## How to run

1. run (creates the cluster): `kind create cluster --config "k8s/kind/config.yaml"` on the project folder;
2. run:
   `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml`
3. If on windows, run: `.\scripts\deploy-all.ps1` on the terminal (power shell)
4. Open "C:\Windows\System32\drivers\etc\hosts" as adm and add:

| Host                     |
|--------------------------|
| 127.0.0.1 api.local      |
| 127.0.0.1 keycloak.local |
| 127.0.0.1 config.local   |
| 127.0.0.1 kafka-ui.local |

## Ports used by the services

| Service       | port | targetPort |
|---------------|------|------------|
| api-gateway   | 8085 | 8085       |
| config-server | 8888 | 8888       |
| Keycloak      | 8080 | 8080       |
| Postgress     | 5432 | 5432       |
| Kafka UI      | 8081 | 8081       |

## Usefull commands

- kubectl apply -f "k8s/keycloak/deployment.yaml"
- kubectl rollout restart deployment keycloak -n bidflow

- kubectl apply
  -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
- kubectl get pods -n ingress-nginx
- kind delete cluster --name bidflow

- make the database accessible: kubectl port-forward svc/postgres 5432:5432 -n bidflow
- make the kafka-ui accessible: kubectl -n kafka port-forward svc/my-cluster-kafka-bootstrap 9092:9092

- kubectl get ns
- kubectl get nodes
- kubectl get pods -n bidflow
- kubectl get svc -n bidflow