node {
    checkout scm
    
    try {
        stage 'Run unit/integration tests'
        sh 'whoami'
        sh 'make test'
        
        stage 'Build application artifacts'
        sh 'make build'
        
        stage 'Create release environment and run acceptance tests'
        sh 'make release'
        
        stage 'Tag and publish release image'
        sh 'make tag latest \$(git rev-parse --short HEAD) \$(git tag --points-at HEAD)'
        sh 'make buildtag main \$(git tag --points-at HEAD)'
        
        withEnv(["DOCKER_USER=${DOCKER_USER}",
                "COKVER_PASSWORD=${DOCKER_PASSWORD}"]) {
                    sh 'make login'
                }
        
        sh 'make publish'
    }
    finally {
        stage 'Collect test reports'
        step([$class: 'JUnitResultArchiver', testResults: '**/reports/*.xml'])
        
        stage 'Clean up'
        sh 'make clean'
        sh 'make logout'
    }
}