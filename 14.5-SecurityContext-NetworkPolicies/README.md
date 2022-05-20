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
```bash
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
      proj: netpol
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
```bash
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
      proj: netpol
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
```bash
kubectl apply -f ./14.5/templates/main/
deployment.apps/backend created
service/backend created
deployment.apps/frontend created
service/frontend created
```

Проверяем поды:
```bash
kubectl get deploy,po -o wide
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS          IMAGES                                  SELECTOR
deployment.apps/backend    1/1     1            1           8d    network-multitool   praqma/network-multitool:alpine-extra   app=backend
deployment.apps/frontend   1/1     1            1           8d    network-multitool   praqma/network-multitool:alpine-extra   app=frontend

NAME                            READY   STATUS    RESTARTS   AGE    IP              NODE    NOMINATED NODE   READINESS GATES
pod/backend-f785447b9-p2d8h     1/1     Running   0          7d5h   10.233.90.132   node1   <none>           <none>
pod/frontend-8645d9cb9c-rxhss   1/1     Running   0          7d5h   10.233.90.131   node1   <none>           <none>
```

Проверяем доступы:
```bash
kubectl exec frontend-8645d9cb9c-rxhss -- curl -s -m 1 backend
Praqma Network MultiTool (with NGINX) - backend-f785447b9-p2d8h - 10.233.90.132
# доступ есть

kubectl exec frontend-8645d9cb9c-rxhss -- curl -I -s 'https://netology.ru'
HTTP/2 200
date: Fri, 20 May 2022 12:24:41 GMT
content-type: text/html; charset=utf-8
x-frame-options: SAMEORIGIN
x-frame-options: SAMEORIGIN
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
x-download-options: noopen
x-permitted-cross-domain-policies: none
referrer-policy: strict-origin-when-cross-origin
vary: Accept, Origin
cache-control: max-age=0, private, must-revalidate
x-request-id: 04ce121b-b30e-4d15-aeea-c8d91f25a210
x-runtime: 0.029787
cf-cache-status: DYNAMIC
expect-ct: max-age=604800, report-uri="https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct"
server: cloudflare
cf-ray: 70e50cfdea249b9a-FRA
alt-svc: h3=":443"; ma=86400, h3-29=":443"; ma=86400
# доступ во вне есть

kubectl exec backend-f785447b9-p2d8h -- curl -s -m 1 frontend
Praqma Network MultiTool (with NGINX) - frontend-8645d9cb9c-rxhss - 10.233.90.131
# доступ есть

kubectl exec backend-f785447b9-p2d8h -- curl -I -s 'https://netology.ru'
HTTP/2 200
date: Fri, 20 May 2022 12:26:20 GMT
content-type: text/html; charset=utf-8
x-frame-options: SAMEORIGIN
x-frame-options: SAMEORIGIN
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
x-download-options: noopen
x-permitted-cross-domain-policies: none
referrer-policy: strict-origin-when-cross-origin
vary: Accept, Origin
cache-control: max-age=0, private, must-revalidate
x-request-id: 485c6d07-6408-4b45-ba41-6831cf65fc1b
x-runtime: 0.026904
cf-cache-status: DYNAMIC
expect-ct: max-age=604800, report-uri="https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct"
server: cloudflare
cf-ray: 70e50f6518ac8fce-FRA
alt-svc: h3=":443"; ma=86400, h3-29=":443"; ma=86400
# доступ во вне есть
```

Проверяем список правил NetworkPolicy:
```bash
kubectl get netpol
No resources found in securitycontext namespace.
```


Создаём NetworkPolicy с разрешениями (14.5/templates/network-policy/netpol.yaml)
```bash
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: deny-frontend
  namespace: securitycontext
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: backend
      ports:
        - port: 80
        - protocol: TCP
  egress:
    - {}

---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: deny-backend
  namespace: securitycontext
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: frontend
      ports:
        - port: 80
        - protocol: TCP
  egress:
    - to:
      - podSelector:
          matchLabels:
            app: frontend
      ports:
        - port: 80
        - protocol: TCP

```

Применяем NetworkPolicy
```bash
kubectl apply -f ./14.5/templates/network-policy/
networkpolicy.networking.k8s.io/deny-frontend created
networkpolicy.networking.k8s.io/deny-backend created
```

Проверяем список правил NetworkPolicy:
```bash
kubectl get netpol
NAME            POD-SELECTOR   AGE
deny-backend    app=backend    23s
deny-frontend   app=frontend   23
```

Проверяем доступ:
```bash
kubectl exec frontend-8645d9cb9c-rxhss -- curl -s -m 1 backend
Praqma Network MultiTool (with NGINX) - backend-f785447b9-ndcmq - 10.233.90.125
# доступ есть

kubectl exec frontend-8645d9cb9c-rxhss -- curl -I -s 'https://netology.ru'
HTTP/2 200
date: Wed, 11 May 2022 08:22:03 GMT
content-type: text/html; charset=utf-8
x-frame-options: SAMEORIGIN
x-frame-options: SAMEORIGIN
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
x-download-options: noopen
x-permitted-cross-domain-policies: none
referrer-policy: strict-origin-when-cross-origin
vary: Accept, Origin
cache-control: max-age=0, private, must-revalidate
x-request-id: 1c4d6a10-5bb0-49dc-8bd0-c2e7b8e52ae6
x-runtime: 0.029323
cf-cache-status: DYNAMIC
expect-ct: max-age=604800, report-uri="https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct"
server: cloudflare
cf-ray: 709981309c789072-FRA
alt-svc: h3=":443"; ma=86400, h3-29=":443"; ma=86400
# доступ во вне есть

kubectl exec backend-f785447b9-p2d8h -- curl -s -m 1 frontend
command terminated with exit code 28
# доступа нет !!

kubectl exec backend-f785447b9-p2d8h -- curl -I -s 'https://netology.ru'
command terminated with exit code 6
# доступа во вне нет
```

Так и не смог разобраться почему нет доступа, если прописываешь egress, отличный от:
```bash
  egress:
    - {}
```

Пробовал различные варианты:
```bash
  egress:
    - to:
      - podSelector:
          matchLabels:
            app: frontend
      ports:
        - port: 80
        - protocol: TCP
```
И так:
```bash
  egress:
    - to:
      - ipBlock:
          cidr: 10.233.90.0/24
      ports:
        - port: 80
        - protocol: TCP
```
И так:
```bash
  egress:
    - to:
      - namespaceSelector:
          matchLabels:
            networking/namespace: securitycontext
        podSelector:
          matchLabels: {}
      ports:
        - protocol: TCP
```
И даже так:
```bash
  egress:
    - to:
        - namespaceSelector:
            matchLabels: {}
          podSelector: {}
      ports:
        - protocol: TCP
```
Странно, что не работает, потому что в описании подов лейбл есть:
```bash
sudo kubectl describe pod frontend-8645d9cb9c-rxhss
...
Labels:       app=frontend
              pod-template-hash=8645d9cb9c
...
```

Не может отрезолвить и всё.
При обращении с бекэнда на фронт выдаёт ошибку:
```bash
kubectl exec backend-f785447b9-p2d8h -- curl -s frontend -vvvv
* Could not resolve host: frontend
* Closing connection 0
command terminated with exit code 6
```

Возможно, как то по другому нужно прописывать если под поднимается деплойментом или зависит от сервиса.

Будет время полистаю мануалы поподробнее.
