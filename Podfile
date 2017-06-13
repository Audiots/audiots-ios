#source 'git@github.com:perfectsense/cocoapods-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'Audiots' do
    ##### PSD DataSource #####
    #pod 'PSDDataSource', '0.2.7'
    pod 'Toast', '3.0'
    #pod 'XLPagerTabStrip', '2.0.0'
    pod 'iCloudDocumentSync', '7.4.1'
    pod 'UrbanAirship-iOS-SDK', '7.0.2'
    pod 'TGCameraViewController', '2.2.8'
    pod 'MZTimerLabel', '0.5.4'
end

target 'Audiots Keyboard' do
    ##### PSD DataSource #####
    #pod 'PSDDataSource', '0.2.7'
    pod 'Toast', '3.0'
    #pod 'XLPagerTabStrip', '2.0.0'
    pod 'iCloudDocumentSync', '7.4.1'
end

# Cocoapods doesn't play nice with projects that already use their own xcconfig file
# modify the Pods.xcconfig file, prefixing with "PODS_" -- developement team
# needs to ensure that these definitions get pushed into their upstream xcconfig file

post_install do |installer|

#modify the PCH file generated for each target
#remapping the names of the classes
#    installer.pods_project.targets.each do |target|
#        target.build_configurations.each do |config|
#            if config.name == 'Release'
#                puts target.name
#                prefixHeader = config.build_settings['GCC_PREFIX_HEADER']
#                if (prefixHeader)
#                    prefixHeaderFile = File.read(installer.config.project_pods_root + prefixHeader)
#                    namespaceHeader = "../../../NamespacedDependencies.h"
#                    File.open(installer.config.project_pods_root + prefixHeader, 'w') { |file| file.write("#import \""+namespaceHeader+"\"\n\n" + prefixHeaderFile) }
#                end
#            end
#        end
#    end
end
