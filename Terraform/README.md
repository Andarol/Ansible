WordPress install on EC2 via Terragrunt
Структура:
.
- main.tf # Опис інфраструктури
- variables.tf # Вхідні параметри
- outputs.tf # Вивід IP-адреси
- wordpress.sh # Bash-скрипт для встановлення WordPress
- terragrunt.hcl # Terragrunt обгортка
Розгортання:
terragrunt init
terragrunt apply
Доступ:
http://<EC2_PUBLIC_IP>
