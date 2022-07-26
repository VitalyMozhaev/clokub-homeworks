# Ответы на домашнее задание к занятию "15.1. Организация сети"

Домашнее задание будет состоять из обязательной части, которую необходимо выполнить на провайдере Яндекс.Облако и дополнительной части в AWS по желанию. Все домашние задания в 15 блоке связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
Все задания требуется выполнить с помощью Terraform, результатом выполненного домашнего задания будет код в репозитории. 

Перед началом работ следует настроить доступ до облачных ресурсов из Terraform используя материалы прошлых лекций и [ДЗ](https://github.com/netology-code/virt-homeworks/tree/master/07-terraform-02-syntax ). А также заранее выбрать регион (в случае AWS) и зону.

---
## Задание 1. Яндекс.Облако (обязательное к выполнению)

1. Создать VPC.
- Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 192.168.10.0/24.
- Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1
- Создать в этой публичной подсети виртуалку с публичным IP и подключиться к ней, убедиться что есть доступ к интернету.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 192.168.20.0/24.
- Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс
- Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее и убедиться что есть доступ к интернету

Resource terraform для ЯО
- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet)
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table)
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance)
---

# Подготовка:
```bash
# Создаём каталог
mkdir -p /home/hwuser/terraform/1.1.9/
cd /home/hwuser/terraform/1.1.9/

# Загружаем архив
wget https://hashicorp-releases.website.yandexcloud.net/terraform/1.1.9/terraform_1.1.9_linux_amd64.zip

# Распаковываем
sudo unzip terraform_1.1.9_linux_amd64.zip -d /usr/bin
Archive:  terraform_1.1.9_linux_amd64.zip
  inflating: /usr/bin/terraform
  
# Делаем симлинк
# sudo ln -s /home/hwuser/terraform/1.1.9/terraform /usr/bin/terraform

# Проверяем
terraform -v
Terraform v1.1.9
on linux_amd64
```

Создаём файл конфигурации Terraform CLI (~/.terraformrc):
```bash
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

Далее создаём рабочую директорию и переходим в неё:
```bash
mkdir cloud-terraform
cd cloud-terraform/
```

Создаём файлы terraform:

https://github.com/VitalyMozhaev/clokub-homeworks/tree/main/15.1-YC-networks/terraform


Выполняем первый запуск:
```bash
terraform init

Initializing the backend...

Initializing provider plugins...
- Finding yandex-cloud/yandex versions matching "0.75.0"...
- Installing yandex-cloud/yandex v0.75.0...
- Installed yandex-cloud/yandex v0.75.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Проверяем конфигурацию:
```bash
terraform validate
Success! The configuration is valid.
```

После проверки конфигурации выполните команду `terraform plan`

В терминале будет выведен список ресурсов с параметрами. Это проверочный этап: ресурсы не будут созданы. Если в конфигурации есть ошибки, Terraform на них укажет.
```bash
terraform plan

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-nat will be created
  + resource "yandex_compute_instance" "vm-nat" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      ...
      
    }

  # yandex_compute_instance.vm-private will be created
  + resource "yandex_compute_instance" "vm-private" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      ...
      
    }

  # yandex_compute_instance.vm-public will be created
  + resource "yandex_compute_instance" "vm-public" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)

    }

  # yandex_vpc_network.netology-network will be created
  + resource "yandex_vpc_network" "netology-network" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "netology-network"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_route_table.private-route-table will be created
  + resource "yandex_vpc_route_table" "private-route-table" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + labels     = (known after apply)
      + network_id = (known after apply)

      + static_route {
          + destination_prefix = "0.0.0.0/0"
          + next_hop_address   = "192.168.10.254"
        }
    }

  # yandex_vpc_subnet.subnet-private will be created
  + resource "yandex_vpc_subnet" "subnet-private" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-private"
      + network_id     = (known after apply)
      + route_table_id = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.20.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.subnet-public will be created
  + resource "yandex_vpc_subnet" "subnet-public" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-public"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external-ip-vm-private = (known after apply)
  + external-ip-vm-public  = (known after apply)
  + internal-ip-vm-nat     = "192.168.10.254"
  + internal-ip-vm-private = (known after apply)
  + internal-ip-vm-public  = (known after apply)

```

Чтобы создать ресурсы выполните команду:
```bash
terraform apply
...
Вывод плана создаваемых ресурсов и этапов создания
...
yandex_compute_instance.vm-private: Creation complete after 42s [id=fhm3t9gj3aq3ci4ac57i]
yandex_compute_instance.vm-nat: Creation complete after 45s [id=fhm9sb2ht9597n7std96]
yandex_compute_instance.vm-public: Creation complete after 51s [id=fhm08t9haj3tna2nrc7n]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

external-ip-vm-private = ""
external-ip-vm-public = "51.250.89.104"
internal-ip-vm-nat = "192.168.10.254"
internal-ip-vm-private = "192.168.20.6"
internal-ip-vm-public = "192.168.10.29"
```

У виртуалки в приватной сети "vm-private" нет внешнего IP, поэтому доступа извне нет.

Подключаемся к виртуалке "vm-public" в публичной сети:
```bash
ssh hwuser@51.250.89.104
The authenticity of host '51.250.89.104 (51.250.89.104)' can't be established.
ECDSA key fingerprint is SHA256:qMIrwfV6fTVDkZG/uLssqfMA16ELdsUAuZ6tua+omu4.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '51.250.89.104' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 18.04.1 LTS (GNU/Linux 4.15.0-29-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.
```

Виртуалка "vm-public" в публичной сети имеет выход во вне:
```bash
ping ya.ru
PING ya.ru (87.250.250.242) 56(84) bytes of data.
64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=58 time=0.556 ms
64 bytes from ya.ru (87.250.250.242): icmp_seq=2 ttl=58 time=0.317 ms
^C
--- ya.ru ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.317/0.436/0.556/0.121 ms
```

Доступа напрямую к виртуалке "vm-private" в приватной сети нет. Подключаемся через виртуалку "vm-public" из публичной сети:
```bash
ssh -J hwuser@51.250.89.104 hwuser@192.168.20.6
The authenticity of host '192.168.20.6 (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:zgKaF+ytk1C6NWhWcfcR3+/vEuqDEQofKVvAPhKtKi8.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.20.6' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 18.04.1 LTS (GNU/Linux 4.15.0-29-generic x86_64)
...
```

Проверяем ip текущей виртуалки:
```bash
ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether d0:0d:3e:a6:13:1a brd ff:ff:ff:ff:ff:ff
    inet 192.168.20.6/24 brd 192.168.20.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::d20d:3eff:fea6:131a/64 scope link
       valid_lft forever preferred_lft forever
```

Мы находимся на виртуалке "vm-private" в приватной сети (192.168.20.0/24). При этом доступ извне к ней напрямую отсутствует.

Проверяем доступ изнутри во вне:
```bash
ping ya.ru
PING ya.ru (87.250.250.242) 56(84) bytes of data.
64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=56 time=2.32 ms
64 bytes from ya.ru (87.250.250.242): icmp_seq=2 ttl=56 time=0.826 ms
^C
--- ya.ru ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.826/1.574/2.323/0.749 ms
```

Доступ есть и трафик идёт через публичную сеть.


## Задание 2*. AWS (необязательное к выполнению)

1. Создать VPC.
- Cоздать пустую VPC с подсетью 10.10.0.0/16.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 10.10.1.0/24
- Разрешить в данной subnet присвоение public IP по-умолчанию. 
- Создать Internet gateway 
- Добавить в таблицу маршрутизации маршрут, направляющий весь исходящий трафик в Internet gateway.
- Создать security group с разрешающими правилами на SSH и ICMP. Привязать данную security-group на все создаваемые в данном ДЗ виртуалки
- Создать в этой подсети виртуалку и убедиться, что инстанс имеет публичный IP. Подключиться к ней, убедиться что есть доступ к интернету.
- Добавить NAT gateway в public subnet.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 10.10.2.0/24
- Создать отдельную таблицу маршрутизации и привязать ее к private-подсети
- Добавить Route, направляющий весь исходящий трафик private сети в NAT.
- Создать виртуалку в приватной сети.
- Подключиться к ней по SSH по приватному IP через виртуалку, созданную ранее в публичной подсети и убедиться, что с виртуалки есть выход в интернет.

Resource terraform
- [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
- [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
- [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)
