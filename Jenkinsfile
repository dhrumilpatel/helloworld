node ("worker") {
        
               def DOCKERHUB_CREDENTIALS=credentials('blueberrie')

        
                stage('Build') {
                        steps {
                                sh "docker build -t gs-spring-boot/goal-hello-world:latest ."
                        }
                }
                stage('Login') {
                        steps {
                                sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
                        }
                }
                stage('Push') {
                        steps {
                                sh "docker image push blueberrie/goal-hello-world:latest"
                        }
                }
       
        post {
                always {
                        sh "docker logout"
                }
        }

}
