#!/bin/bash
#0. cleanup
docker rm -f $(docker ps -a -q)
sudo rm -rf /var/jenkins_home/workspace/tsunami-scanner
sudo rm -rf /var/jenkins_home/workspace/gloat
#1. clone and build tsunami image
git clone https://github.com/google/tsunami-security-scanner.git
cd tsunami-security-scanner
docker build -t tsunami .

#2. Run vulnerable machine for test
docker run --name vulnerable -p 8888:8888 -d jupyter/base-notebook start-notebook.sh --NotebookApp.token=''

#3. Run unvulnerable machine for test
docker run --name unvulnerable -P -d nginxdemos/hello

#4. generate servers list
sudo mkdir -p /var/jenkins_home/workspace/tsunami-scanner
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vulnerable > /tmp/servers.list
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unvulnerable >> /tmp/servers.list
sudo cp /tmp/servers.list /var/jenkins_home/workspace/tsunami-scanner/servers.list
cd ..

#5. clone my repo
git clone https://github.com/arieldiner/gloat.git
cd gloat/jcasc

#6. replace localhost with IP
sed -i "s/localhost/$(hostname -I | awk '{print $1}')/g" casc.yaml

#7. inject ip list as input parameter
ip_list=$(paste -d, -s /tmp/servers.list)
sed -i "s/10.10.10.10/$ip_list/g" casc.yaml


#8. build jenkins as code
docker build -t jenkins:jcasc .

#9. run smtp serevr
docker run -d -p 8025:8025 -p 1025:1025 mailhog/mailhog

#10. run jenkins as code

sudo docker run --name jenkins -u root -v $(which docker):/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock -v /var/jenkins_home/workspace/tsunami-scanner:/var/jenkins_home/workspace/tsunami-scanner --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc

