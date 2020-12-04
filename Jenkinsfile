pipeline {
    agent {
        label 'dockerslave'
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "auto_maven"
    }
    environment {
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
    }

  
    stages {
        stage('Clear running apps') {
           steps {
               // Clear previous instances of app built
               sh 'docker rm -f pandaapp || true'
           }
        }
        stage('Pull Code') {
            steps {
                // Get some code from a GitHub repository
               checkout scm
            }
        }
        stage('Build and Junit') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn clean install"
            }
        }
        stage('Build Docker image'){
            steps {
                sh "mvn package -Pdocker11 -DskipTests"
            }
        }

        stage('Run Docker app') {
            steps {

               sh "docker run -d -p 8080:8083 --name pandaapp -t ${IMAGE}:${VERSION} --network=docker_network"
            }
        }

        stage('Test Selenium') {
            steps {
                sh "mvn test -Pselenium"
            }
        }
        stage('Deploy jar to artifactory') {
            steps {
                configFileProvider([configFile(fileId: 'MavenSettings', variable: 'MAVEN_SETTINGS')]) {
                    sh "mvn -gs $MAVEN_SETTINGS deploy -Dmaven.test.skip=true -e"
                }
            } 
        }


    }
        post {
                always { 
                    sh 'docker stop pandaapp'
                    deleteDir()
                }
        }
}

