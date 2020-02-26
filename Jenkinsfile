def xcodeproj = 'xDrip.xcodeproj'
def xcarchive_name = "xDrip.xcarchive"
def build_scheme = 'xDrip'
def test_scheme = 'xDrip'
def bundle_id = 'com.faifly.xDrip'
def simulator_device_id = 'D4B27995-A4F3-4465-8D72-B147831C6509'

def sendFailNotification(e) {
    
}

def sendStatusNotification(status) {
    sh "curl --location --request POST 'https://api.github.com/repos/Faifly/xDrip/statuses/${env.GIT_COMMIT}' --header 'Content-Type: application/json' --header 'Authorization: token ${env.GITHUB_OAUTH_TOKEN}' --data-raw '{\"state\": \"${status}\", \"target_url\": \"${env.BUILD_URL}\", \"description\": \"The build status is ${status}\", \"context\": \"continuous-integration/jenkins\"}'"
}

// Configure Jenkins to keep the last 200 build results and the last 50 build artifacts for this job
properties([buildDiscarder(logRotator(artifactNumToKeepStr: '50', numToKeepStr: '100'))])

node {
    try {
        stage('Check project') {
            sendStatusNotification("pending")
            checkout scm
            
            // Delete and recreate build directory
            dir('build') {
                deleteDir()
            }

            sh "mkdir -p build"
        }

        stage('Build') {
            wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
                sh "xcrun xcodebuild -scheme '${build_scheme}' -destination 'id=${simulator_device_id}' clean build | tee build/xcodebuild.log | xcpretty"
            }
        }

        stage('Test') {
            wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
                // Launch simulator and delete app if installed
                sh "xcrun simctl boot ${simulator_device_id} || true"
                sh "xcrun simctl uninstall ${simulator_device_id} ${bundle_id} || true"

                // Run tests and generate coverage
                sh "xcodebuild -scheme '${test_scheme}' -configuration Debug -destination 'id=${simulator_device_id}' test | tee build/xcodebuild-test.log | xcpretty -r junit --output build/reports/junit.xml"
                sh "/usr/local/lib/ruby/gems/2.7.0/bin/slather coverage --scheme '${test_scheme}' --cobertura-xml --output-directory build/coverage '${xcodeproj}'"
            }

            step([$class: 'JUnitResultArchiver', testResults: 'build/reports/*.xml'])
            step([$class: 'CoberturaPublisher', autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'build/coverage/*.xml', failNoReports: true, failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'UTF_8', zoomCoverageChart: true])
        }
        
        stage('Notifications') {
            sendStatusNotification("success")
        }
    } catch (e) {
        sendStatusNotification("failure")
        sendFailNotification(e)
        throw e
    }
}
