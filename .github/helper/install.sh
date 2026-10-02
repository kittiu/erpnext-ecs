#!/bin/bash
# Throwaway bench for the server-tests workflow: frappe v16 + erpnext + hrms + erpnext_ecs,
# installed on one site. Adapted from frappe/hrms's .github/helper/install.sh.
set -e

cd ~ || exit

sudo apt update
sudo apt install -y libcups2-dev redis-server mariadb-client libmariadb-dev

pip install frappe-bench

branch="${FRAPPE_BRANCH:-version-16}"

git clone https://github.com/frappe/frappe --branch "${branch}" --depth 1
bench init --skip-assets --frappe-path ~/frappe --python "$(which python)" frappe-bench

mkdir ~/frappe-bench/sites/test_site
cp "${GITHUB_WORKSPACE}/.github/helper/site_config.json" ~/frappe-bench/sites/test_site/

mariadb --host 127.0.0.1 --port 3306 -u root -proot -e "SET GLOBAL character_set_server = 'utf8mb4'"
mariadb --host 127.0.0.1 --port 3306 -u root -proot -e "SET GLOBAL collation_server = 'utf8mb4_unicode_ci'"
mariadb --host 127.0.0.1 --port 3306 -u root -proot -e "CREATE USER 'test_frappe'@'localhost' IDENTIFIED BY 'test_frappe'"
mariadb --host 127.0.0.1 --port 3306 -u root -proot -e "CREATE DATABASE test_frappe"
mariadb --host 127.0.0.1 --port 3306 -u root -proot -e "GRANT ALL PRIVILEGES ON \`test_frappe\`.* TO 'test_frappe'@'localhost'"
mariadb --host 127.0.0.1 --port 3306 -u root -proot -e "FLUSH PRIVILEGES"

cd ~/frappe-bench || exit

sed -i 's/watch:/# watch:/g' Procfile
sed -i 's/schedule:/# schedule:/g' Procfile
sed -i 's/socketio:/# socketio:/g' Procfile
sed -i 's/redis_socketio:/# redis_socketio:/g' Procfile

bench get-app erpnext --branch "${branch}" --resolve-deps
bench get-app hrms --branch "${branch}"
bench get-app "${GITHUB_WORKSPACE}"
bench setup requirements --dev

bench --site test_site reinstall --yes
bench --site test_site install-app erpnext
bench --site test_site install-app hrms
bench --site test_site install-app erpnext_ecs
