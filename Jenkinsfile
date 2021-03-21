def singleIp = false
def newips = [:]

              pipeline {
                agent any
                stages {
                  stage ('Get Address List From File') {
			    steps {
			        script{
			             def exists = fileExists "$WORKSPACE/servers.list"
			            echo "${exists}"
			            if(!exists){
					    error("servers.list does not exist at $WORKSPACE/servers.list")
			            } 
			        }
			    }
                  }
			  stage ('parallel stage'){
				steps{
				    script{
    			            def filePath = readFile "$WORKSPACE/servers.list"
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
				                }
				            }
				            parallel newips
				         
				    }

				}
			  }
                }
                
                post{
                    success{
                        script{
                            if (fileExists('detected.txt')) {
                                mail bcc: '', body: "Vulnerability detected see report at $BUILD_URL", cc: '', from: 'arieldiner@gloat.com', replyTo: '', subject: 'Vulnerability detected', to: 'ronen@gloat.com'
                            } else {
                               echo 'VULNERABILITY NOT DETECTED'
                            }
                        }
                    }
                }
              }
