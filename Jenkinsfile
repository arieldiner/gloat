def singleIp = false
def ips_list = []
def newips = [:]

              pipeline {
                agent any
                stages {
                  stage ('Get Ip Addresses') {
			    steps {
			        script{
                        ips_list="${IP_ADDRESS}".split(',')
                        echo "${ips_list}"
			        }
			    }
                  }
			  stage ('parallel stage'){
				steps{
				    script{
    			         //   def filePath = readFile "$WORKSPACE/servers.list"
    			         //   def lines = filePath.readLines()
    			            sh "rm detected.txt || true"
    			         //   echo "${lines}"
				            ips_list.each {
				                line ->
				                newips[line] = {
				                    sh "docker run  --network='host' -v \"\$WORKSPACE/logs\":/usr/tsunami/logs tsunami --ip-v4-target=${line} --scan-results-local-output-format=JSON --scan-results-local-output-filename=logs/${line}.json"
				                    def isDetected = (sh(returnStdout:true, script: "cat $WORKSPACE/logs/${line}.json | grep VULNERABILITY_VERIFIED || true")).trim()
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
