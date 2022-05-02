# Ответы на домашнее задание к занятию "14.5 SecurityContext, NetworkPolicies"

## Подготовка

```bash
# Создаём пространство имён:
kubectl create ns securitycontext
namespace/securitycontext created

# Переключаемся на пространство имён securitycontext
kubectl config set-context --current --namespace=securitycontext
Context "kubernetes-admin@cluster.local" modified.

# Проверяем текущий namespace:
kubectl config view --minify | grep namespace:
    namespace: securitycontext
```

## Задача 1: Рассмотрите пример 14.5/example-security-context.yml

Создайте модуль

```bash
kubectl apply -f 14.5/example-security-context.yml
pod/security-context-demo created

kubectl get po
NAME                    READY   STATUS             RESTARTS      AGE
security-context-demo   0/1     CrashLoopBackOff   1 (10s ago)   15s
```

Проверьте установленные настройки внутри контейнера

```bash
kubectl logs security-context-demo
uid=1000 gid=3000 groups=3000
```
Так и есть!

## Задача 2 (*): Рассмотрите пример 14.5/example-network-policy.yml

Создайте два модуля. Для первого модуля разрешите доступ к внешнему миру
и ко второму контейнеру. Для второго модуля разрешите связь только с
первым контейнером. Проверьте корректность настроек.

Для проверки network policy создадим два deployment: `frontend` и `backend`.

Создаём deployment `frontend` (14.5/templates/main/frontend.yaml):
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
  namespace: securitycontext
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - image: praqma/network-multitool:alpine-extra
          imagePullPolicy: IfNotPresent
          name: network-multitool
      terminationGracePeriodSeconds: 30

---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: securitycontext
spec:
  ports:
    - name: web
      port: 80
  selector:
    app: frontend

```

Создаём deployment `backend` (14.5/templates/main/backend.yaml):
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: backend
  name: backend
  namespace: securitycontext
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - image: praqma/network-multitool:alpine-extra
          imagePullPolicy: IfNotPresent
          name: network-multitool
      terminationGracePeriodSeconds: 30

---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: securitycontext
spec:
  ports:
    - name: web
      port: 80
  selector:
    app: backend

```

Поднимаем поды:
```
sudo kubectl apply -f ./14.5/templates/main/
deployment.apps/frontend created
service/frontend created
deployment.apps/backend created
service/backend created
```

Проверяем поды:
```
sudo kubectl get deploy,po -o wide

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS          IMAGES                                  SELECTOR
deployment.apps/backend    1/1     1            1           24s   network-multitool   praqma/network-multitool:alpine-extra   app=backend
deployment.apps/frontend   1/1     1            1           24s   network-multitool   praqma/network-multitool:alpine-extra   app=frontend

NAME                            READY   STATUS    RESTARTS   AGE   IP              NODE    NOMINATED NODE   READINESS GATES
pod/backend-f785447b9-ndcmq     1/1     Running   0          24s   10.233.90.124   node1   <none>           <none>
pod/frontend-8645d9cb9c-chfxv   1/1     Running   0          24s   10.233.96.38    node2   <none>           <none>
```

Проверяем доступы:
```
sudo kubectl exec frontend-8645d9cb9c-chfxv -- curl -s -m 1 backend
Praqma Network MultiTool (with NGINX) - backend-f785447b9-ndcmq - 10.233.90.124
# доступ есть

sudo kubectl exec frontend-8645d9cb9c-chfxv -- curl -H ...
# доступ во вне есть

sudo kubectl exec backend-f785447b9-ndcmq -- curl -s -m 1 frontend
Praqma Network MultiTool (with NGINX) - frontend-8645d9cb9c-chfxv - 10.233.96.38
# доступ есть

sudo kubectl exec frontend-8645d9cb9c-chfxv -- curl -H ...
# доступ во вне есть
```

Проверяем список правил NetworkPolicy:
```
# sudo kubectl get networkpolicies         # Есть короткая запись и это здорово!
sudo kubectl get netpol
No resources found in securitycontext namespace.
```


Создаём NetworkPolicy с разрешениями (14.5/templates/network-policy/netpol.yaml)

```
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend
  namespace: securitycontext
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
    - Ingress
  ingress:
    - from:
      {}
    - to:
      {}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend
  namespace: securitycontext
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: frontend
    - to:
      - podSelector:
          matchLabels:
            app: frontend

```

Применяем NetworkPolicy
```
sudo kubectl apply -f ./14.5/templates/network-policy/
networkpolicy.networking.k8s.io/default-deny-ingress unchanged
networkpolicy.networking.k8s.io/backend created
networkpolicy.networking.k8s.io/frontend created
```

Проверяем список правил NetworkPolicy:
```
sudo kubectl get netpol
NAME                   POD-SELECTOR   AGE
backend                app=backend    22s
default-deny-ingress   <none>         4m43s
frontend               app=frontend   22s
```

Проверяем доступ:
```
sudo kubectl exec frontend-8645d9cb9c-2dpgh -- curl -s -m 1 backend
Praqma Network MultiTool (with NGINX) - backend-f785447b9-6s9qn - 10.233.90.26
# доступ есть

sudo kubectl exec backend-f785447b9-6s9qn -- curl -s -m 1 frontend
command terminated with exit code 28
# доступа нет
```
