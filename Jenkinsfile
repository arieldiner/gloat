def singleIp = false
def newips = [:]

              pipeline {
                agent any
                environment{
                    IPADDRESS=""
                    LIST=""
                    
                }
                stages {
                  stage ('Get Address List From File') {
		  //    agent {docker { image 'test:latest' }}
			    steps {
			        script{
			             def exists = fileExists "$WORKSPACE/ipaddresslist.txt"
			            echo "${exists}"
			            if("${IP_ADDRESS}" == "" ){
			                if(!exists){
			                    echo "file is not exist"
			                    sh "docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unauthenticated-jupyter-notebook-4 > \$WORKSPACE/ipaddresslist.txt"
			                    sh "docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unauthenticated-jupyter-notebook-6 >> \$WORKSPACE/ipaddresslist.txt"
			                }
    			        
			            } else{
			                echo "I'm going to run tsunami on ip address : ${IP_ADDRESS}"
			                singleIp=true
			            }

			        }

			    }
                  }
			  stage ('parallel stage'){
				steps{
				    script{
				         if(singleIp){
				             echo "I'm going to run tsunami on ip address : ${IP_ADDRESS}"
				         }else{
    			            def filePath = readFile "$WORKSPACE/ipaddresslist.txt"
    			            def lines = filePath.readLines()
    			            sh "rm detected.txt || true"
    			            echo "${lines}"
				            lines.each {
				                line ->
				                newips[line] = {
				                    sh "docker run  --network='host' -v \"\$WORKSPACE/logs\":/usr/tsunami/logs tsunami --ip-v4-target=${line} --scan-results-local-output-format=JSON --scan-results-local-output-filename=logs/${line}.json"
				                    def isDetected = (sh(returnStdout:true, script: "cat $WORKSPACE/logs/${line}.json | grep VULNERABILITY_VERIFIED")).trim()
				                    def length = isDetected.length()
				                    if( isDetected.length() > 0 ){
				                        echo "VULNERABILITY DETECTED - Archiving report ${line}.json"
				                        archiveArtifacts artifacts: "logs/${line}.json", fingerprint: true
				                        sh "echo detected > $WORKSPACE/detected.txt"
				                    }
				                    
				                    
				                    // def isDetected = (sh(returnStdout:true, script: "cat $WORKSPACE/logs/${line}.json | jq '.fullDetectionReports | length'")).trim()
				                    // if(isDetected > 0){
				                    //     echo "vulnerability detected"
				                    //     echo "reporting to "
				                    // }
				                }
				            }
				            parallel newips
				         }
				    }

				}
			  }
                }
                
                post{
                    success{
                        script{
                            if (fileExists('detected.txt')) {
                                echo 'VULNERABILITY DETECTED - please see attached reports'
                            } else {
                               echo 'VULNERABILITY NOT DETECTED'
                            }
                        }
                    }
                }
              }
