              pipeline {
                agent any
                stages {
                  stage ('Build tsunami') {
		      agent {docker { image 'test:latest' }}
			    steps {
			      //git branch: "master", url: 'https://github.com/google/tsunami-security-scanner.git'
			      sh "python --version"
			    }
                  }
			  stage ('Run tsunami'){
				steps{
				   //sh "sudo docker run --name unauthenticated-jupyter-notebook -p 8888:8888 -d jupyter/base-notebook start-notebook.sh --NotebookApp.token=''"
				    //sh "docker run  --network='host' -v '\$WORKSPACE/logs':/usr/tsunami/logs tsunami"
					//-v \$(which docker):/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock
					sh "ls"
				}
			  }
                }
              }
