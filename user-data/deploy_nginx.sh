#!/bin/bash
#Actualizando paquetes
sudo apt-get -y update 
sudo apt-get -y upgrade
sudo apt-get -y autoremove
echo "paquetes actualizados" >> /home/ubuntu/install.log
#instalando SSM agente
sudo snap install amazon-ssm-agent --classic
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
#instalando Nginx
sudo apt-get install nginx -y
sudo rm -rf  /var/www/html/index.nginx-debian.html
sudo touch /var/www/html/index.nginx-debian.html
sudo echo "Server 01 NGINX" >> /var/www/html/index.nginx-debian.html

