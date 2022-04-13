# Ответы на домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать секрет?

Создаём ключ:
```bash
openssl genrsa -out cert.key 4096
Generating RSA private key, 4096 bit long modulus (2 primes)
.........++++
............................................................................++++
e is 65537 (0x010001)
```

Создаём самоподписанный сертификат:
```bash
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt -subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
```

Создаём в кластере tls секрет domain-cert с только что созданными ключом и сертификатом:
```bash
kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
secret/domain-cert created
```

### Как просмотреть список секретов?

```bash
kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-q7fcq   kubernetes.io/service-account-token   3      15d
domain-cert           kubernetes.io/tls                     2      28s
```

### Как просмотреть секрет?

```bash
kubectl get secret domain-cert
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      44s

kubectl describe secret domain-cert
kubeuser@cp1:~/secrets$ sudo kubectl describe secret domain-cert
Name:         domain-cert
Namespace:    objects
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1944 bytes
tls.key:  3243 bytes
```

### Как получить информацию в формате YAML и/или JSON?

В формате YAML:
```bash
kubectl get secret domain-cert -o yaml
apiVersion: v1
data:
  tls.crt: ***
  tls.key: ***
kind: Secret
metadata:
  creationTimestamp: "2022-04-13T21:33:48Z"
  name: domain-cert
  namespace: objects
  resourceVersion: "76558"
  uid: 72726ade-e292-49ab-9da3-19403685f3aa
type: kubernetes.io/tls
```

В формате JSON:
```bash
kubectl get secret domain-cert -o json
{
    "apiVersion": "v1",
    "data": {
        "tls.crt": "***",
        "tls.key": "***"
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2022-04-13T21:33:48Z",
        "name": "domain-cert",
        "namespace": "objects",
        "resourceVersion": "76558",
        "uid": "72726ade-e292-49ab-9da3-19403685f3aa"
    },
    "type": "kubernetes.io/tls"
}
```

### Как выгрузить секрет и сохранить его в файл?

В формате JSON:
```bash
kubectl get secrets -o json > secrets.json

cat secrets.json
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "data": {
                "ca.crt": "***",
                "namespace": "b2JqZWN0cw==",
                "token": "***"
            },
            "kind": "Secret",
            "metadata": {
                "annotations": {
                    "kubernetes.io/service-account.name": "default",
                    "kubernetes.io/service-account.uid": "587258e7-2a5f-4db1-baa3-656d2ec57c47"
                },
                "creationTimestamp": "2022-03-28T21:36:38Z",
                "name": "default-token-q7fcq",
                "namespace": "objects",
                "resourceVersion": "43309",
                "uid": "0abd744b-2bf6-4557-a9c8-4a4b597ec5fd"
            },
            "type": "kubernetes.io/service-account-token"
        },
        {
            "apiVersion": "v1",
            "data": {
                "tls.crt": "***",
                "tls.key": "***"
            },
            "kind": "Secret",
            "metadata": {
                "creationTimestamp": "2022-04-13T21:33:48Z",
                "name": "domain-cert",
                "namespace": "objects",
                "resourceVersion": "76558",
                "uid": "72726ade-e292-49ab-9da3-19403685f3aa"
            },
            "type": "kubernetes.io/tls"
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
```

В формате YAML:
```bash
kubectl get secret domain-cert -o yaml > domain-cert.yml

cat domain-cert.yml
apiVersion: v1
data:
  tls.crt: ***
  tls.key: ***
kind: Secret
metadata:
  creationTimestamp: "2022-04-13T21:33:48Z"
  name: domain-cert
  namespace: objects
  resourceVersion: "76558"
  uid: 72726ade-e292-49ab-9da3-19403685f3aa
type: kubernetes.io/tls
```

### Как удалить секрет?

```bash
kubectl delete secret domain-cert
secret "domain-cert" deleted

kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-q7fcq   kubernetes.io/service-account-token   3      16d
```

### Как загрузить секрет из файла?

```bash
kubectl apply -f domain-cert.yml
secret/domain-cert created

kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-q7fcq   kubernetes.io/service-account-token   3      16d
domain-cert           kubernetes.io/tls                     2      13s
```

## Задача 2 (*): Работа с секретами внутри модуля

Выберите любимый образ контейнера, подключите секреты и проверьте их доступность
как в виде переменных окружения, так и в виде примонтированного тома.

```
С огромным сожалением приходится пропустить дополнительное задание,
оставляя его до тех пор, когда будет свободный часок-другой, чтобы детально проработать.
```

---

## PS:
В предыдущих ДЗ все команды выполнял непосредственно на мастер ноде cp1, поэтому использовал и описывал  `sudo kubectl ...`.
