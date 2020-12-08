pipeline {
    agent {
        label 'dockerslave'
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "auto_maven"
        terraform "Terraform"
    }
    environment {
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
        ANSIBLE = tool name: 'ansible', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
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
        stage('Run Terraform'){
            steps {
                dir('infrastructure/terraform'){
                    sh "terraform init && terraform apply -auto-approve"
                }
            }
        }
        stage('Copy Ansible Role'){
            steps {
             sh "cp -r infrastructure/ansible/panda/ /etc/ansible/roles/"
            }
        }
        stage('Run Ansible'){
            steps {
                dir('infrastructure/ansible'){
                    sh "chmod 600 ../panda_kurs.pem"
                    sh "ansible-playbook -i ./inventory playbook.yml"
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


