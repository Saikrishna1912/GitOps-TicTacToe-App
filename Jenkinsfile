pipeline {
    agent any
    
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
        DOCKER_TAG_IMAGE = "soravkumarsharma/tictactoe:latest"
    }
    
    stages {
        stage('Clean WorkSace') {
            steps {
                cleanWs()
            }
        }
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/soravkumarsharma/TIC-TAC-TOE-DevSecOps-Project.git'
            }
        }
        stage('Static Code Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                  sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=TicTacToe \
                         -Dsonar.projectKey=TicTacToe'''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    timeout(5) {
                      def qg = waitForQualityGate()
                      if (qg.status != 'OK'){
                          echo "Pipeline aborted due to Quality Gate failure: ${qg.status}"
                      }
                    }
                }
            }
        }
        stage('File System Scan - Trivy') {
            steps {
                sh "trivy fs . > fs_report.txt"
            }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker') {
                      sh "docker build -t tictactoe ."
                      sh "docker tag tictactoe ${DOCKER_TAG_IMAGE}"
                      sh "docker push ${DOCKER_TAG_IMAGE}"
                    }
                }
            }
        }
        stage('Docker Image Scan') {
            steps {
                sh "trivy image ${DOCKER_TAG_IMAGE} > image_report.txt"
            }
        }
        stage('Deploy to Container') {
            steps {
                sh "docker run -d -p 3000:3000 ${DOCKER_TAG_IMAGE}"
            }
        }
    }
}
