def nomis_ci_environments = [
    "nomis-dev",
]

def deploy(environments) {
    for (environment_name in environments) {
        build job: "Nomis/Environments/${environment_name}/Deploy_Infrastructure", parameters: [[$class: 'BooleanParameterValue', name: 'confirmation', value: false]], wait: false
    }
}

pipeline {

    agent { label "jenkins_slave" }

    options {
        ansiColor('xterm')
    }

    stages {

        stage('setup') {
            steps {
                checkout scm
            }
        }

        stage('Trigger deployment') {
            steps {
                deploy(nomis_ci_environments)
            }
        }

    }

}
