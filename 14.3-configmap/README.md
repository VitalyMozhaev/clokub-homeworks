# Ответы на домашнее задание к занятию "14.3 Карты конфигураций"

## Подготовка

```bash
# Создаём пространство имён:
kubectl create ns configmap
namespace/configmap created

# Переключаемся на пространство имён configmap
kubectl config set-context --current --namespace=configmap
Context "kubernetes-admin@cluster.local" modified.

# Проверяем текущий namespace:
kubectl config view --minify | grep namespace:
    namespace: configmap
```

## Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните задачу 1 как справочный материал.

### Как создать карту конфигураций?

```bash
kubectl create configmap nginx-config --from-file=nginx.conf
configmap/nginx-config created

kubectl create configmap domain --from-literal=name=netology.ru
configmap/domain created
```

### Как просмотреть список карт конфигураций?

```bash
kubectl get configmaps
NAME               DATA   AGE
domain             1      37s
kube-root-ca.crt   1      11m
nginx-config       1      66s

# Одинаковый вывод:
kubectl get configmap
NAME               DATA   AGE
domain             1      78s
kube-root-ca.crt   1      12m
nginx-config       1      107s
```

### Как просмотреть карту конфигурации?

```bash
kubectl get configmap nginx-config
NAME           DATA   AGE
nginx-config   1      2m51s

kubectl describe configmap domain
Name:         domain
Namespace:    configmap
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
netology.ru

BinaryData
====

Events:  <none>
```

### Как получить информацию в формате YAML и/или JSON?

В формате YAML:
```bash
kubectl get configmap nginx-config -o yaml
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-04-28T14:55:56Z"
  name: nginx-config
  namespace: configmap
  resourceVersion: "711469"
  uid: d07e4489-60a7-45cd-9351-a378166b51cb
```

В формате JSON:
```bash
kubectl get configmap domain -o json
{
    "apiVersion": "v1",
    "data": {
        "name": "netology.ru"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-04-28T14:56:25Z",
        "name": "domain",
        "namespace": "configmap",
        "resourceVersion": "711517",
        "uid": "1d9599cf-b991-4c15-8b43-5467f0f0af12"
    }
}
```

### Как выгрузить карту конфигурации и сохранить его в файл?

В формате YAML:
```bash
kubectl get configmap nginx-config -o yaml > nginx-config.yml
cat nginx-config.yml
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-04-28T14:55:56Z"
  name: nginx-config
  namespace: configmap
  resourceVersion: "711469"
  uid: d07e4489-60a7-45cd-9351-a378166b51cb
```

В формате JSON:
```bash
kubectl get configmaps -o json > configmaps.json
cat 
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "data": {
                "name": "netology.ru"
            },
            "kind": "ConfigMap",
            "metadata": {
                "creationTimestamp": "2022-04-28T14:56:25Z",
                "name": "domain",
                "namespace": "configmap",
                "resourceVersion": "711517",
                "uid": "1d9599cf-b991-4c15-8b43-5467f0f0af12"
            }
        },
        {
            "apiVersion": "v1",
            "data": {
                "ca.crt": "***"
            },
            "kind": "ConfigMap",
            "metadata": {
                "annotations": {
                    "kubernetes.io/description": "Contains a CA bundle that can be used to verify the kube-apiserver when using internal endpoints such as the internal service IP or kubernetes.default.svc. No other usage is guaranteed across distributions of Kubernetes clusters."
                },
                "creationTimestamp": "2022-04-28T14:45:31Z",
                "name": "kube-root-ca.crt",
                "namespace": "configmap",
                "resourceVersion": "710414",
                "uid": "3308d878-4ade-41f3-8c33-b5ec6f793604"
            }
        },
        {
            "apiVersion": "v1",
            "data": {
                "nginx.conf": "server {\n    listen 80;\n    server_name  netology.ru www.netology.ru;\n    access_log  /var/log/nginx/domains/netology.ru-access.log  main;\n    error_log   /var/log/nginx/domains/netology.ru-error.log info;\n    location / {\n        include proxy_params;\n        proxy_pass http://10.10.10.10:8080/;\n    }\n}\n"
            },
            "kind": "ConfigMap",
            "metadata": {
                "creationTimestamp": "2022-04-28T14:55:56Z",
                "name": "nginx-config",
                "namespace": "configmap",
                "resourceVersion": "711469",
                "uid": "d07e4489-60a7-45cd-9351-a378166b51cb"
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
```

### Как удалить карту конфигурации?

```bash
kubectl delete configmap nginx-config
configmap "nginx-config" deleted

sudo kubectl get configmaps
NAME               DATA   AGE
domain             1      13m
kube-root-ca.crt   1      24m
```

### Как загрузить карту конфигурации из файла?

```bash
kubectl apply -f nginx-config.yml
configmap/nginx-config created

kubectl get configmaps
NAME               DATA   AGE
domain             1      14m
kube-root-ca.crt   1      25m
nginx-config       1      10s
```

## Задача 2 (*): Работа с картами конфигураций внутри модуля

Выбрать любимый образ контейнера, подключить карты конфигураций и проверить
их доступность как в виде переменных окружения, так и в виде примонтированного
тома
