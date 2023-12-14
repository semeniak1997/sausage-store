pipeline {
    agent any

    tools {
        maven 'maven-3.8.1'
        //jdk 'jdk16'
        nodejs 'node-16'
    }

    stages {
        stage("Build & Test backend"){
            steps{
                dir("backend") {
                    sh 'mvn package'
                }
            }
            post{
                success{
                    junit 'backend/target/surefire-reports/**/*.xml'
                }
                failure{
                    echo "========A execution failed========"
                }
            }
        }

        stage('Build frontend') {
            steps {
                dir("frontend") {
                    sh 'npm install' 
                    sh 'npm run build' 
                }
            }
        }

        stage('Save artifacts') {
            steps {
                archiveArtifacts(artifacts: 'backend/target/sausage-store-0.0.1-SNAPSHOT.jar') 
                archiveArtifacts(artifacts: 'frontend/dist/frontend/*')
            }
            post {
                success{
                sh  (""" curl -X POST -H 'Content-type: application/json' \
                    --data '{"chat_id": "-1002007326342", "text": "Никита Семеняк собрал приложение." }' \
                    https://api.telegram.org/bot5933756043:AAE8JLL5KIzgrNBeTP5e-1bkbJy4YRoeGjs/sendMessage 
                    """)
                }
                failure{
            echo "========pipeline execution failed========"
        }
        }
        
        }
        
    }

    }
    
