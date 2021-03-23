def BUILD_INSTANCE_IP
def STAGING_INSTANCE_IP
node() {
    stage ('AWS Configure'){
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awscreds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
        sh(script:"""printf "%s\n%s\neu-central-1\njson" "${AWS_ACCESS_KEY_ID}" "${AWS_SECRET_ACCESS_KEY}" | aws configure --profile default""", returnStdout: true)
        }
    }
    stage ('Git checkout'){
        git branch: 'tf-ec2', credentialsId: 'gitcreds', url: 'https://github.com/greatestfen/main-task'
    }
    stage ('Terraform Init'){
        sh 'terraform init'
    }
    stage ('Terraform Apply'){
        sh 'terraform apply -auto-approve'
    }
    stage ('Gather instance IP') {
        sleep time: 3, unit: 'MINUTES'
        env.BUILD_INSTANCE_IP = sh (script: """aws --region eu-central-1 ec2 describe-instances --filter \
                "Name=instance-state-name,Values=running" --query \
                "Reservations[*].Instances[*].[PublicIpAddress, Tags[?Key=='Name'].Value|[0]]" \
                --output text | grep Build | cut -f1""", returnStdout: true).trim()
        env.STAGING_INSTANCE_IP = sh (script: """aws --region eu-central-1 ec2 describe-instances --filter \
                "Name=instance-state-name,Values=running" --query \
                "Reservations[*].Instances[*].[PublicIpAddress, Tags[?Key=='Name'].Value|[0]]" \
                --output text | grep Staging | cut -f1""", returnStdout: true).trim()
    }
    stage ('Running playbook on the Build server') {
        sh("""printf "[instances]\n${env.BUILD_INSTANCE_IP}\n" > ./hosts""")
        git branch: 'build', credentialsId: 'gitcreds', url: 'https://github.com/greatestfen/main-task'
        withCredentials([sshUserPrivateKey(credentialsId: 't2micro', keyFileVariable: 'AWS_KEY', passphraseVariable: '', usernameVariable: 'SSH_USER')]) {
            sh('ansible-playbook main.yml -i hosts -u ubuntu --private-key ${AWS_KEY}')
        }
    }
    stage ('Push Image to Dockerhub') {
        sh("""printf "[instances]\n${env.STAGING_INSTANCE_IP}\n" > ./hosts""")
        withCredentials([usernamePassword(credentialsId: 'gitcreds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
            sshagent(['t2micro']) {
                sh """ssh -o StrictHostKeyChecking=no ubuntu@${env.BUILD_INSTANCE_IP} << EOF
                    docker login --username=${DOCKER_USER} --password=${DOCKER_PASS}
                    docker push greatestfen/ansible-docker:latest
EOF"""
            }
        }
    }
    stage ('Pull and Run Image on the Staging server') {
        withCredentials([sshUserPrivateKey(credentialsId: 't2micro', keyFileVariable: 'AWS_KEY', passphraseVariable: '', usernameVariable: 'SSH_USER')]) {
            git branch: 'deploy', credentialsId: 'gitcreds', url: 'https://github.com/greatestfen/main-task'
                sh('ansible-playbook main.yml -i hosts -u ubuntu --private-key ${AWS_KEY}')
        }
    }
}