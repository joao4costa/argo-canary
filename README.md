# Argo Canary Node.js Project

Este projeto é uma API Node.js simples configurada com Argo Rollouts para estratégia de deployment Canary.
Abaixo estão os comandos essenciais para desenvolvimento local, build de imagens e acesso à aplicação.

## 1. Gerar e Disponibilizar Imagem Docker

Sempre que alterar o código (`server.js`) ou `Dockerfile`, siga estes passos para atualizar a aplicação.

### Build da Imagem
Gera a imagem Docker localmente. Lembre-se de incrementar a tag da versão (ex: 1.0.0 -> 1.0.1).

```bash
# Exemplo para versão 1.0.0
sudo docker build -t argo-canary:1.0.0 .
```

### Carregar Imagem no Cluster Local (Kind/Minikube)
O Kubernetes local não consegue baixar imagens locais automaticamente, é preciso carregá-las.

**Para Kind:**
```bash
# Se o cluster se chamar "kind" (padrão)
sudo kind load docker-image argo-canary:1.0.0

# Se o cluster tiver outro nome (ex: argotest)
sudo kind load docker-image argo-canary:1.0.0 --name argotest
```

**Para Minikube:**
```bash
minikube image load argo-canary:1.0.0
```

---

## 2. Atualizar o Rollout

Edite o arquivo `manifests/rollout.yaml` alterando a tag da imagem para a nova versão que você acabou de buildar:

```yaml
    spec:
      containers:
        - name: argo-canary
          image: "argo-canary:1.0.0" # <-- Atualize aqui
```

Depois, faça o commit e push para o repositório Git monitorado pelo ArgoCD.

---

## 3. Acessar Aplicações (Port-Forward)

Como estamos rodando localmente sem Ingress externo, usamos `port-forward` para acessar os serviços.

### Acessar ArgoCD (Interface)
Acessível em: [https://localhost:8080](https://localhost:8080)
*(O usuário padrão geralmente é `admin`)*.

```bash
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Acessar a Aplicação (API)
Acessível em: [http://localhost:8888](http://localhost:8888)

```bash
sudo kubectl port-forward svc/argo-canary 8888:80
```

Para testar (em outro terminal):
```bash
curl http://localhost:8888
# Retorno esperado: {"version":"1.0.0"}
```

---

## 4. Validar Divisão de Tráfego (Watch Script)

Para visualizar as versões respondendo em tempo real (Canary), utilize o script auxiliar:

```bash
./watch-traffic.sh
```
Ele fará requisições a cada 3 segundos e pintará a versão no terminal. Isso ajuda a ver a transição (ex: 75% v1, 25% v2).
---
```
sudo kubectl run -it --rm --restart=Never --image=curlimages/curl tester -- sh -c 'for i in $(seq 1 20); do curl -s http://argo-canary/ | grep version; sleep 0.2; done'
```
