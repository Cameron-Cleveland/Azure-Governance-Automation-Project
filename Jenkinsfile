pipeline {
    agent any

    environment {
        SCAN_FAILED = "false"
    }

    stages {
        stage('Build & Prep') {
            steps {
                echo 'Pulling Healthcare Infrastructure Code...'
                git branch: 'main', 
                    credentialsId: 'GITHUB_SCM_AUTH1', 
                    url: 'https://github.com/Cameron-Cleveland/Azure-Governance-Automation-Project.git'
            }
        }

        stage('Static Analysis (SonarQube)') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner' 
                    withCredentials([string(credentialsId: 'SONAR_TOKEN_ID', variable: 'SONAR_TOKEN')]) {
                        echo "Running SonarQube quality check..."
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=Cameron-Cleveland_secure-aws-goverance \
                            -Dsonar.organization=cameron-cleveland \
                            -Dsonar.host.url=https://sonarcloud.io \
                            -Dsonar.login=${SONAR_TOKEN} \
                            -Dsonar.sources=.
                        """
                    }
                }
            }
        }

        stage('Governance Check (Trivy)') {
            steps {
                script {
                    echo 'Running Trivy: Immediate Policy & Landing Zone alignment check...'
                    // Fail the build if HIGH or CRITICAL issues are found
                    sh "trivy config . --severity HIGH,CRITICAL --exit-code 1"
                }
            }
        }

        stage('Security Deep Dive (Snyk)') {
            steps {
                script {
                    def snykHome = tool 'snyk-cli'
                    withCredentials([string(credentialsId: 'SNYK_TOKEN_TEXT', variable: 'SNYK_TOKEN')]) {
                        echo 'Running Snyk: Deep vulnerability analysis...'
                        sh "${snykHome}/snyk-linux iac test . --token=${SNYK_TOKEN} --severity-threshold=high"
                    }
                }
            }
        }

        stage('Terraform Azure Plan') {
            steps {
                script {
                    // Pulls the path from Jenkins Global Tool Configuration
                    def tfHome = tool 'terraform'
                    
                    withCredentials([
                        string(credentialsId: 'Application ID', variable: 'ARM_CLIENT_ID'),
                        string(credentialsId: 'Azure-Secrets-ID', variable: 'ARM_CLIENT_SECRET'),
                        string(credentialsId: 'Directory ID', variable: 'ARM_TENANT_ID'),
                        string(credentialsId: 'azure subscription ID', variable: 'ARM_SUBSCRIPTION_ID')
                    ]) {
                        // We add the tfHome/bin directory to the PATH so 'terraform' works
                        sh """
                            export PATH=\$PATH:${tfHome}
                            export ARM_CLIENT_ID=$ARM_CLIENT_ID
                            export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
                            export ARM_TENANT_ID=$ARM_TENANT_ID
                            export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
                            
                            terraform init
                            terraform plan -out=healthcare_plan
                        """
                    }
                }
            }
        }
    }
}