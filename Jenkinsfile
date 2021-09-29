pipeline {
	agent {
		node {
			label 'bionic'
		}
	}
    triggers {
        cron(env.BRANCH_NAME == 'master' ? '@weekly' : '')
    }
    options {
        timeout(time: 120, unit: 'MINUTES')
        parallelsAlwaysFailFast()
        retry(2)
    }
	stages {
		stage('Test Images') {
			when {
				beforeAgent true
				anyOf {
					buildingTag()
					branch 'master'
					changeRequest target: 'master'
				}
			}
			agent {
				node {
					label 'bionic'
				}
			}
			steps {
				parallel (
					alpine: {
						sh "echo HELLO ALPINE"
					},
					centos: {
						sh "echo HELLO CENTOS"
					},
					rhel: {
						sh "echo HELLO RHEL"
					},
					ubuntu: {
						sh "echo HELLO UBUNTU"
					}
				)
			}
		}
	}
}
