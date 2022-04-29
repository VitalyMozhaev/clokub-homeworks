# Ответы на домашнее задание к занятию "14.4 Сервис-аккаунты"

## Подготовка

```bash
# Создаём пространство имён:
kubectl create ns serviceacc
namespace/serviceacc created

# Переключаемся на пространство имён serviceacc
kubectl config set-context --current --namespace=serviceacc
Context "kubernetes-admin@cluster.local" modified.

# Проверяем текущий namespace:
kubectl config view --minify | grep namespace:
    namespace: serviceacc
```

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать сервис-аккаунт?

```bash
kubectl create serviceaccount netology
serviceaccount/netology created
```

### Как просмотреть список сервис-акаунтов?

```bash
kubectl get serviceaccounts
NAME       SECRETS   AGE
default    1         62s
netology   1         20s

kubectl get serviceaccount
NAME       SECRETS   AGE
default    1         70s
netology   1         28s
```

### Как получить информацию в формате YAML и/или JSON?

В формате YAML:
```bash
kubectl get serviceaccount netology -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-04-29T13:14:00Z"
  name: netology
  namespace: serviceacc
  resourceVersion: "718834"
  uid: 6c0edacf-041d-455e-8d57-c4371acc8246
secrets:
- name: netology-token-58szc
```

В формате JSON:
```bash
kubectl get serviceaccount default -o json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2022-04-29T13:13:18Z",
        "name": "default",
        "namespace": "serviceacc",
        "resourceVersion": "718761",
        "uid": "3eaa3929-af62-4c47-988b-1f4acfca59e1"
    },
    "secrets": [
        {
            "name": "default-token-699nj"
        }
    ]
}
```

### Как выгрузить сервис-акаунты и сохранить его в файл?

В формате YAML:
```bash
kubectl get serviceaccount netology -o yaml > netology.yml
cat netology.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-04-29T13:14:00Z"
  name: netology
  namespace: serviceacc
  resourceVersion: "718834"
  uid: 6c0edacf-041d-455e-8d57-c4371acc8246
secrets:
- name: netology-token-58szc
```

В формате JSON:
```bash
kubectl get serviceaccounts -o json > serviceaccounts.json
cat serviceaccounts.json
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "kind": "ServiceAccount",
            "metadata": {
                "creationTimestamp": "2022-04-29T13:13:18Z",
                "name": "default",
                "namespace": "serviceacc",
                "resourceVersion": "718761",
                "uid": "3eaa3929-af62-4c47-988b-1f4acfca59e1"
            },
            "secrets": [
                {
                    "name": "default-token-699nj"
                }
            ]
        },
        {
            "apiVersion": "v1",
            "kind": "ServiceAccount",
            "metadata": {
                "creationTimestamp": "2022-04-29T13:14:00Z",
                "name": "netology",
                "namespace": "serviceacc",
                "resourceVersion": "718834",
                "uid": "6c0edacf-041d-455e-8d57-c4371acc8246"
            },
            "secrets": [
                {
                    "name": "netology-token-58szc"
                }
            ]
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
```

### Как удалить сервис-акаунт?

```bash
kubectl delete serviceaccount netology
serviceaccount "netology" deleted

kubectl get serviceaccounts
NAME      SECRETS   AGE
default   1         5m51s
```

### Как загрузить сервис-акаунт из файла?

```bash
kubectl apply -f netology.yml
serviceaccount/netology created

kubectl get serviceaccounts
NAME       SECRETS   AGE
default    1         6m53s
netology   2         12s
```

## Задача 2 (*): Работа с сервис-акаунтами внутри модуля

Выбрать любимый образ контейнера, подключить сервис-акаунты и проверить
доступность API Kubernetes

```bash
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
If you don't see a command prompt, try pressing enter.
sh-5.1#
```

Просмотреть переменные среды

```bash
env | grep KUBE
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT_443_TCP=tcp://10.233.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.233.0.1
KUBERNETES_SERVICE_HOST=10.233.0.1
KUBERNETES_PORT=tcp://10.233.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
```

Получить значения переменных

```bash
K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
SADIR=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat $SADIR/token)
CACERT=$SADIR/ca.crt
NAMESPACE=$(cat $SADIR/namespace)
```

Для этого запишем переменные:
```bash
export K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
export SADIR=/var/run/secrets/kubernetes.io/serviceaccount
export TOKEN=$(cat $SADIR/token)
export CACERT=$SADIR/ca.crt
export NAMESPACE=$(cat $SADIR/namespace)
```

Получаем значения:
```bash
env | grep K8S
K8S=https://10.233.0.1:443
env | grep SADIR
SADIR=/var/run/secrets/kubernetes.io/serviceaccount
env | grep TOKEN
TOKEN=eyJhbGciOiJSUzI1N***
 env | grep CACERT
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
env | grep NAMESPACE
NAMESPACE=serviceacc
```

Подключаемся к API

```bash
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
    {
***
# Длинный длинный вывод
***
    {
      "name": "services/status",
      "singularName": "",
      "namespaced": true,
      "kind": "Service",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    }
  ]
```

В случае с minikube может быть другой адрес и порт, который можно взять здесь

```bash
cat ~/.kube/config
```

или здесь

```bash
kubectl cluster-info
```
