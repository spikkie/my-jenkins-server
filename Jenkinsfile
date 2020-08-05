#!groovy
try {
    //TODO install jenkins-timestamper timestamps {
    timeout(time: 10000, unit: 'MINUTES') {
        env.ARTIFACT = "${env.JOB_NAME.split('/')[0]}-hello"
        node('docker-agent1') {
            def scmVars
            def app
            String project = env.PROJECT
            def imageName = "jenkins-server-${PROJECT}"

            wrap([$class: 'Xvnc', takeScreenshot: false, useXauthority: true]) {
                stage('Clone repository') {
                    try {
                        deleteDir()
                        /* Let's make sure we have the repository cloned to our workspace */
                        scmVars = checkout scm
                        currentBuild.result = 'SUCCESS'
                    }
                    catch (all) {
                        println "Clone Repo Something failed, I should sound the klaxons! "+all
                        currentBuild.result = 'FAILURE'
                        throw all
                    }
                }

                docker.withRegistry('https://geneesplaats.nl') {
                    stage('Build image') {
                        try {
                            String workspaceDir  = env.WORKSPACE
                            def svnversionnumber = scmVars.SVN_REVISION
                            def buildTimestamp   = sh(script: 'date -Iseconds', returnStdout: true)

                            withCredentials([usernamePassword(credentialsId: 'd9a7a9c8-76a8-44a4-a544-402d13a9b183', 
                                             passwordVariable: 'SVN_PASSWORD',
                                             usernameVariable: 'SVN_USERNAME')]) {
                                withEnv(["BUILD_TIMESTAMP=${buildTimestamp}",
                                "SDL_AUDIODRIVER=dummy",
                                "SVN_REVISION=${scmVars.SVN_REVISION}",
                                "SVN_URL=${scmVars.SVN_URL}",
                                "WORKSPACE=${workspaceDir}",
                                "AXIVION_DATABASE_PATH=${HOME}/axivion/databases",
                                "SDKTARGETSYSROOT=/opt/windriver/sdk-7.0-host/sysroots/core2-32-wrs-linux/",
                                "DEBUG_SCRIPT=1",
                                ]) {
                                   app = docker.build("${imageName}", "--no-cache .")
                                }
                            }
                            currentBuild.result = 'SUCCESS'
                        }
                        catch (all) {
                            println " Build Image Something failed!"+all
                            currentBuild.result = 'FAILURE'
                            throw all
                        }
                        finally {
                            node {
                                stage('finally') {
                                    sh "echo build image finally"
                                    // TODO 
                                    // based upon DEBUG variable run this unendles loop 
                                    //sh "while true; do sleep 1;done"
                                }
                            }
                        }

                        stage('Test image') {
                            try {
                                app.inside { sh 'echo "Tests passed"'}
                                currentBuild.result = 'SUCCESS'
                            }
                            catch (all) {
                                println " Test Image Something failed, I should sound the klaxons!"+all
                                currentBuild.result = 'FAILURE'
                                throw all
                            }
                        }

                        stage('Push image') {
                            try {
                                docker.withRegistry('https://geneesplaats.nl') {
                                    /* Finally, we'll push the image with two tags:
                                    * First, the incremental build number from Jenkins
                                    * Second, the 'latest' tag.
                                    * Pushing multiple tags is cheap, as all the layers are reused. */
                                    app.push("latest")
                                    app.push("${env.BUILD_NUMBER}")
                                }
                                currentBuild.result = 'SUCCESS'
                            }
                            catch (all) {
                                println " Push Image Something failed, I should sound the klaxons!"+all
                                currentBuild.result = 'FAILURE'
                                throw all
                            }
                        }
                    }
                }
            }
        }
    }
    // } TODO install jenkins-timestamper timestamps 
}
catch (all) {
    currentBuild.result = 'FAILURE'
    println " Main try Build Image Something failed!"+all
}
finally {
    println "Finally "
    println "currentBuild.result :"+currentBuild.result
}

