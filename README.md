# Дипломный проект

### Структура проекта:
- **kind**
Конфигурацию terraform, kind и jenkins
- **apps**
Исходный код приложения
- **app-chart**
Helm-сhart для развёртывания приложения
- **prometheus**
Конфигурация prometheus

## Краткое описание работы проекта:
- Инфраструктура описана в terraform и запускается в AWS.
- При запуске виртуальной машины, запускается скрипт init.sh, который устанавливается kind и запускает kubernetes кластер.
- В kubernetes создаются:
    * устанавливается nginx-ingress controller
    * неймспейсы jenkins (для запуска jenkins server и создания агентов), monitoring (для prometheus), main и dev (для развёртывания приложения веток main и dev оответственно).
    * необходимые секреты
    * устанавливается jenkins server и конфигурируется из кода
- В jenkins server запускается multibranch pipeline, который отслеживает ветки main и dev.
- Пайплайн организован следующим образом:
    * стэйджи: Prepare, Create List of Stages to run in Parallel, Helm list, Telegram message, Helm install и post actions.
        - Prepare - подготавливает список приложений, которые необходимо собрать
        - Create List of Stages to run in Parallel - создаёт список стейджей их запуска параллельно; устанавливает количество одновременно запускаемых стейджей
        - Helm list - проверяет установлено ли приложение
        - Telegram message - отправляет сообщение в телеграм о необходимости подтвердить установку приложения
        - Helm install - устанавливает либо обновляет приложение в зависимости от значения переменной IS_CHART_RELEASED
        - post - реализована отправка сообщения в телеграм по результатам сборки и очистка рабочего пространства

## Перед запуском проекта необходимо:
- Установить awscli
```
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
- Настроить профиль aws
```
aws configure --profile <имя профиля>
```
- Активировать профиль aws
```
export AWS_PROFILE=<имя профиля>
```
- Установить Terraform
https://developer.hashicorp.com/terraform/downloads
```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```
- Сгенерировать ssh-ключ и положить в файл kind/key.tf
- Создать файл .env по аналогии с .env_example и в нём указать необходимые переменые, а именно: GITHUB_TOKEN, TG_TOKEN, TG_CHAT_ID, JENKINS_PASSWORD
- Создать токен доступа гитхаб с доступом на чтение и запись пакетов
- Создать файл .dockerconfigjson по инструкции ниже. Необходимо использовать логин github и токен доступа.

```
echo -n "username:123123adsfasdf123123" | base64
dXNlcm5hbWU6MTIzMTIzYWRzZmFzZGYxMjMxMjM=
```
Create file with contant:
```bash
{
    "auths":
    {
        "ghcr.io":
            {
                "auth":"dXNlcm5hbWU6MTIzMTIzYWRzZmFzZGYxMjMxMjM="
            }
    }
}
```

## Запуск проекта
- Перейти в директорию kind и проинициализировать terraform
```
terraform init
```
- Применить конфигурацию terraform
```
terraform apply --auto-approve
```
**После запуска проекта в аутпутах мы получим ip-адрес виртуальной машин. Его необходимо добавить в hosts**
```
<ip-адрес> jenkins
<ip-адрес> prometheus
<ip-адрес> blackbox
```

## Доступ к проекту
- После редактирования hosts можно зайти на каждый сервис по dns именам
**автоматический запуск prometheus и blackbox не настроен ввиду нехватки ресурсов виртуальной машины**

## Мониторинг
- Для мониторинга kubernetes устанавливается prometheus
- Для мониторинга приложения устанавливается blackbox exporter

- установка prometheus и blackbox exporter:
Переходим в директорию prometheus и запускаем следующие команды:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install -f prometheus.yaml prometheus prometheus-community/kube-prometheus-stack -n monitoring
helm install -f blackbox.yaml blackbox prometheus-community/prometheus-blackbox-exporter -n monitoring
```

## Удалить проект
- Перейти в директорию kind и проинициализировать terraform
```
terraform destroy --auto-approve
```


------------------------------

закинуть ssh ключ в файл key.tf
создать файлик .token с токеном от гитхаба
env
создать секрет для гитхаба для скачивания из докер реестра



поднимается терраформ и страртует инит скрипт на виртуалке, который инсталит kubectl, docker, kind, создаёт кластер kind и устанавливает nginx-ingress

нужно собрать докер имедж и запулить его на гитхаб


установка prometheus и blackbox exporter: (не устанавливаю, так как не хватает ресурсов виртуалки)
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install -f prometheus.yaml prometheus prometheus-community/kube-prometheus-stack -n monitoring
helm install -f blackbox.yaml blackbox prometheus-community/prometheus-blackbox-exporter -n monitoring
```
