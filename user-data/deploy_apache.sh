#!/bin/bash
#Actualizando paquetes
sudo apt-get -y update 
sudo apt-get -y upgrade
sudo apt-get -y autoremove
echo "paquetes actualizados" >> /home/ubuntu/install.log
#instalando SSM agente
sudo snap install amazon-ssm-agent --classic
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
#instalando Apache
sudo apt-get install apache2 -y
sudo rm -rf  /var/www/html/index.html
sudo touch /var/www/html/index.html
sudo echo "Server 02 APACHE" >> /var/www/html/index.html
echo "instalacion finalizada" >> /home/ubuntu/install.log
