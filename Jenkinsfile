// pipeline {
//     agent any

//     environment {
//         DOCKER_TOKEN = credentials('DOCKER_TOKEN') 
//         SSH_PRIVATE_KEY = credentials('ssh-private-key')    
//         USER = credentials('server-user')                  
//         HOST = credentials('server-host')                   
//     }
//     stages {
//         stage('Checkout Code') {
//             steps {
//                 checkout scm
//             }
//         }
//         stage('Build Docker Image') {
//             steps {
//                 script {
//                     docker.build("pungpeee19/1-small-code-lkt:latest")
//                 }
//             }
//         }
//         stage('Push Docker Image') {
//             steps {
//                 script {

//                     sh '''
//                     echo ${DOCKER_TOKEN} | docker login -u pungpeee19 --password-stdin
                    
//                     docker push pungpeee19/1-small-code-lkt:latest
//                     '''
//                 }
//             }
//         }
//         stage('Deploy to Remote Server') {
//             steps {
//                 sshagent(credentials: ['ssh-private-key']) {
//                     sh '''
//                     ssh -o StrictHostKeyChecking=no ${USER}@${HOST} "
//                         echo ${DOCKER_TOKEN} | docker login -u pungpeee19 --password-stdin && \
//                         docker pull pungpeee19/1-small-code-lkt:latest && \
//                         docker run -d --restart=always -p 1001:3000 --name 1-small-code-lkt pungpeee19/1-small-code-lkt:latest
//                     "
//                     '''
//                 }
//             }
//         }
//     }
// }

//  =================================================================Layered security pipeline============================================================================================

pipeline {
    agent any

    environment {
        DOCKER_TOKEN = credentials('DOCKER_TOKEN') 
        SONAR_TOKEN = credentials('sonar-token')          // Replace with Jenkins credentials ID for SonarQube
        SONAR_HOST_URL = credentials('sonar-url') 
        SSH_PRIVATE_KEY = credentials('ssh-private-key')    
        USER = credentials('server-user')                  
        HOST = credentials('server-host')
        SNYK_TOKEN = credentials('SNYK_TOKEN')
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Code - SonarQube Scan-ls') {
            steps {
                script {
                    docker.image('sonarsource/sonar-scanner-cli:latest').inside {
                        sh '''
                        sonar-scanner \
                            -Dsonar.projectKey=1-small-code-lkt \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=${SONAR_HOST_URL} \
                            -Dsonar.login=${SONAR_TOKEN}
                        '''
                    }

                }
            }
        }

        stage('Build Docker Image-ls') {
            steps {
                script {
                    docker.build("pungpeee19/1-small-code-lkt:latest")
                }
            }
        }

        // stage('Build Fix - Snyk Scan Image-ls') {
        //     steps {
        //         withEnv(["NODE_TLS_REJECT_UNAUTHORIZED=0"]) {
        //             sh 'snyk container test --token=$SNYK_TOKEN --org=f7c31024-a0f2-4c34-bdbb-7aef1b436117 --project-name=Pungpeee/1-small-code-lkt pungpeee19/1-small-code-lkt --file=requirements.txt --allow-missing -d'
        //         }
        //             // snykSecurity(
        //             //     snykInstallation: 'snyk@manual',
        //             //     snykTokenId: 'SNYK_TOKEN',
        //             //     projectName: 'Pungpeee/1-small-code-lkt',
        //             //     failOnIssues: false,
        //             //     targetFile: './Dockerfile',
        //             //     severity: 'critical'
        //             // )
        //         // script {
        //         //    withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
        //         //        sh 'snyk container monitor --token=$SNYK_TOKEN pungpeee19/1-small-code-lkt --org=f7c31024-a0f2-4c34-bdbb-7aef1b436117 -d'
        //         //    }
        //         //      sh '''   
        //         //      // # Run Snyk container scan
        //         //         // snyk container test pungpeee19/1-small-code-lkt:latest \
        //         //         //     --severity-threshold=critical \
        //         //         //     --file=./Dockerfile \
        //         //         //     --json
                        
        //         //         // # Attempt to fix vulnerabilities
        //         //         // snyk fix
        //         //     '''
        //         // }
        //     }
        // }
        stage('Push Docker Image-ls') {
            steps {
                script {
                    sh '''
                    echo ${DOCKER_TOKEN} | docker login -u pungpeee19 --password-stdin
                    docker push pungpeee19/1-small-code-lkt:latest
                    '''
                }
            }
        }

        stage('Build - Trivy Vulnerability Scan-ls') {
            steps {
                script {
                    sh ''' 
                        trivy image --severity CRITICAL,HIGH \
                           --cache-dir /mnt/trivy-cache \
                           --pkg-types os,library \
                           --scanners vuln \
                           pungpeee19/1-small-code-lkt:latest

                    '''
                }
            }
        }

        stage('Deploy to Remote Server-ls') {
            steps {
                sshagent(['ssh-private-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ${USER}@${HOST} "
                        echo ${DOCKER_TOKEN} | docker login -u pungpeee19 --password-stdin && \
                        docker pull pungpeee19/1-small-code-lkt:latest && \
                        docker run -d --restart=always -p 1001:3000 --name 1-small-code-lkt pungpeee19/1-small-code-lkt:latest
                    "
                    '''
                }
            }
        }

        stage('OWASP ZAP Scan-ls') {
            steps {
                script {
                    sh '''
                        docker exec devsecops-zap zap-baseline.py -t http://20.212.250.197:1001 -r /zap/wrk/zapreport-1-small-code-lkt-jk.html -I   || true
                          
                    '''
                    sh 'docker cp devsecops-zap:/zap/wrk/zapreport-1-small-code-lkt-jk.html /mnt/zap-reports/zapreport-1-small-code-lkt-jk.html        '
                publishHTML([
                        reportName: 'zapreport-1-small-code-lkt-jenkins',
                        reportDir: '/mnt/zap-reports/',
                        reportFiles: 'zapreport-1-small-code-lkt-jk.html',
                        keepAll: true,
                        allowMissing: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }
    }
}
