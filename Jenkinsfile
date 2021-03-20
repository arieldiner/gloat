              pipeline {
                agent any
                stages {
                  stage ('test') {
                    steps {
                      echo("\$IP_ADDRESS")
                    }
                  }
				  stage ('clone github'){
					steps{
				       git branch: "master", url: 'https://github.com/google/tsunami-security-scanner.git'
					   sh "ls"
					   sh "sudo docker run --name unauthenticated-jupyter-notebook -p 8888:8888 -d jupyter/base-notebook start-notebook.sh --NotebookApp.token=''"
					   sh "sudo docker build -t tsunami ."
					   sh "sudo docker run  --network='host' -v '$WORKSPACE/logs':/usr/tsunami/logs tsunami"
					}
				  }
                }
              }
