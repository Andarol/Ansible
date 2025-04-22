Ansible Runbook: WordPress на EC2
Структура проекту:
- ec2-provision.yml         # Розгортання EC2
- wordpress-setup.yml       # Встановлення WordPress
- destroy.yml               # Видалення EC2
- site.yml                  # Основний playbook
- group_vars/
  - all/
    - pass.yml             # Зашифровані змінні
- templates/                # Шаблони Jinja2
Vault:
group_vars/all/pass.yml містить зашифровані змінні Ansible Vault.
Запуск:
1. Наявність файлу vault.pass із паролем
chmod 600 vault.pass
2. Розгортання EC2:
ansible-playbook ec2-provision.yml --ask-vault-pass
3. Налаштування WordPress:
ansible-playbook site.yml --ask-vault-pass
4. Перехід у браузері:
http://<EC2_PUBLIC_IP>
5. Видалення:
ansible-playbook destroy.yml --vault-password-file vault.pass
