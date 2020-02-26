def xcodeproj = 'xDrip.xcodeproj'
def xcarchive_name = "xDrip.xcarchive"
def build_scheme = 'xDrip'
def test_scheme = 'xDrip'
def bundle_id = 'com.faifly.xDrip'
def simulator_device_id1 = 'D4B27995-A4F3-4465-8D72-B147831C6509'
def simulator_device_id2 = '319907F1-C4AD-4717-AC99-480B071EEE46'
def simulator_device_id3 = '2A4B1772-BC67-49DB-B34D-A011AF2A907E'

def sendFailNotification(e) {
    
}

// Configure Jenkins to keep the last 200 build results and the last 50 build artifacts for this job
properties([buildDiscarder(logRotator(artifactNumToKeepStr: '50', numToKeepStr: '200'))])

node {
    try {
        stage('Check project') {
            checkout scm
            
            // Delete and recreate build directory
            dir('build') {
                deleteDir()
            }

            sh "mkdir -p build"
        }

        stage('Build') {
            wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
                sh "xcrun xcodebuild -scheme '${build_scheme}' -destination 'id=${simulator_device_id1}' -destination 'id=${simulator_device_id2}' -destination 'id=${simulator_device_id3}' clean build | tee build/xcodebuild.log | xcpretty"
            }
        }

        stage('Test') {
            wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
                // Launch simulator and delete app if installed
                sh "xcrun simctl boot ${simulator_device_id1}"
                sh "xcrun simctl uninstall ${simulator_device_id1} ${bundle_id} || true"
                sh "xcrun simctl boot ${simulator_device_id2}"
                sh "xcrun simctl uninstall ${simulator_device_id2} ${bundle_id} || true"
                sh "xcrun simctl boot ${simulator_device_id3}"
                sh "xcrun simctl uninstall ${simulator_device_id3} ${bundle_id} || true"

                // Run tests and generate coverage
                sh "xcodebuild -scheme '${test_scheme}' -configuration Debug -destination 'id=${simulator_device_id1}' -destination 'id=${simulator_device_id2}' -destination 'id=${simulator_device_id3}' test | tee build/xcodebuild-test.log | xcpretty -r junit --output build/reports/junit.xml"
                sh "/usr/local/lib/ruby/gems/2.7.0/bin/slather coverage --scheme '${test_scheme}' --cobertura-xml --output-directory build/coverage '${xcodeproj}'"
            }

            step([$class: 'JUnitResultArchiver', testResults: 'build/reports/*.xml'])
            step([$class: 'CoberturaPublisher', autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'build/coverage/*.xml', failNoReports: true, failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'UTF_8', zoomCoverageChart: true])
        }
    } catch (e) {
        sendFailNotification(e)
        throw e
    }
}
