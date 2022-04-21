# Домашнее задание к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

## Подготовка

```
# Создаём пространство имён:
sudo kubectl create ns vault
namespace/vault created

# Переключаемся на пространство имён vault
sudo kubectl config set-context --current --namespace=vault
Context "kubernetes-admin@cluster.local" modified.

# Проверяем текущий namespace:
sudo kubectl config view --minify | grep namespace:
    namespace: vault
```

## Задача 1: Работа с модулем Vault

Запустить модуль Vault конфигураций через утилиту kubectl в установленном minikube

```bash
kubectl apply -f 14.2/vault-pod.yml
pod/14.2-netology-vault created
service/vault created
```

Получить значение внутреннего IP пода

```bash
kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
[{"ip":"10.233.90.121"}]
```

Примечание: jq - утилита для работы с JSON в командной строке

Установим jq:
```bash
sudo apt install jq -y
```

Запустить второй модуль для использования в качестве клиента

```bash
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
If you don't see a command prompt, try pressing enter.
sh-5.1#
```

Установить дополнительные пакеты

```bash
# pip
dnf -y install pip
...
Installed:
  libxcrypt-compat-4.4.28-1.fc35.x86_64      python3-pip-21.2.3-4.fc35.noarch
  python3-setuptools-57.4.0-1.fc35.noarch

Complete!

# hvac
pip install hvac
...
Installing collected packages: urllib3, idna, charset-normalizer, certifi, six, requests, hvac
Successfully installed certifi-2021.10.8 charset-normalizer-2.0.12 hvac-0.11.2 idna-3.3 requests-2.27.1 six-1.16.0 urllib3-1.26.9
```

Запустить интепретатор Python и выполнить следующий код, предварительно
поменяв IP и токен

```
import hvac
client = hvac.Client(
    url='http://10.233.90.121:8200',
    token='aiphohTaa0eeHei'
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

Результат:
```bash
sh-5.1# python3
Python 3.10.2 (main, Jan 17 2022, 00:00:00) [GCC 11.2.1 20211203 (Red Hat 11.2.1-7)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import hvac
>>> client = hvac.Client(
...     url='http://10.233.90.120:8200',
...     token='aiphohTaa0eeHei'
... )
>>> client.is_authenticated()
True
>>>
>>> # Пишем секрет
>>> client.secrets.kv.v2.create_or_update_secret(
...     path='hvac',
...     secret=dict(netology='Big secret!!!'),
... )
{'request_id': 'c6eacff0-01f1-4a96-cce4-86c870befec6', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'created_time': '2022-04-21T15:18:52.530232615Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>>
>>> # Читаем секрет
>>> client.secrets.kv.v2.read_secret_version(
...     path='hvac',
... )
{'request_id': '2ac22750-f26d-1b02-7835-bbf78cbfb607', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'Big secret!!!'}, 'metadata': {'created_time': '2022-04-21T15:18:52.530232615Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}}, 'wrap_info': None, 'warnings': None, 'auth': None}
```

Теперь посмотрим через web, что у нас получилось:
```bash
kubectl port-forward --address 0.0.0.0 pod/14.2-netology-vault 8200
```

Результат:

![](https://github.com/VitalyMozhaev/clokub-homeworks/blob/main/14.2-vault/vault_hvac.png)

## Задача 2 (*): Работа с секретами внутри модуля

* На основе образа fedora создать модуль;
* Создать секрет, в котором будет указан токен;
* Подключить секрет к модулю;
* Запустить модуль и проверить доступность сервиса Vault.
