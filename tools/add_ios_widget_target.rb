# Beyân – iOS Widget Extension target'ını Runner.xcodeproj'a ekler ve TestFlight imzalama ayarlarını yapılandırır.
# Windows'ta Xcode olmadığı için bu betik GitHub Actions (macOS) üzerinde çalışır.
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../ios/Runner.xcodeproj', __dir__)
PUBSPEC_PATH = File.expand_path('../pubspec.yaml', __dir__)
TARGET_NAME  = 'BeyanWidgetExtension'
TEAM_ID      = '6ABRXTHFD8'

pubspec_version = File.exist?(PUBSPEC_PATH) ? (File.read(PUBSPEC_PATH)[/^version:\s*([^\s+]+)/, 1] || '1.2.14') : '1.2.14'
build_number    = (ENV['GITHUB_RUN_NUMBER'] && !ENV['GITHUB_RUN_NUMBER'].empty?) ? ENV['GITHUB_RUN_NUMBER'] : '1'

project = Xcodeproj::Project.open(PROJECT_PATH)

app_target = project.targets.find { |t| t.name == 'Runner' } or abort('Runner target bulunamadı')
app_bundle_id = app_target.build_configurations.first.build_settings['PRODUCT_BUNDLE_IDENTIFIER']

# 1. Provisioning profillerde App Group ve Keychain desteğini kontrol et ve entitlements dosyalarını oluştur
runner_pp_path = File.join(ENV['RUNNER_TEMP'].to_s, 'build_pp.mobileprovision')
widget_pp_path = File.join(ENV['RUNNER_TEMP'].to_s, 'widget_pp.mobileprovision')
runner_has_app_group = File.exist?(runner_pp_path) && File.binread(runner_pp_path).include?('group.com.smhisk60.beyan')
widget_has_app_group = File.exist?(widget_pp_path) && File.binread(widget_pp_path).include?('group.com.smhisk60.beyan')

def write_entitlements(rel_path, include_app_group)
  full_path = File.expand_path("../ios/#{rel_path}", __dir__)
  app_group_xml = if include_app_group
                    "\t<key>com.apple.security.application-groups</key>\n\t<array>\n\t\t<string>group.com.smhisk60.beyan</string>\n\t</array>\n"
                  else
                    ""
                  end
  content = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    \t<key>keychain-access-groups</key>
    \t<array>
    \t\t<string>$(AppIdentifierPrefix)com.smhisk60.beyan</string>
    \t</array>
    #{app_group_xml}</dict>
    </plist>
  XML
  File.write(full_path, content)
end

write_entitlements('Runner/Runner.entitlements', runner_has_app_group)
write_entitlements('IslamicAppWidget/IslamicAppWidget.entitlements', widget_has_app_group)

app_target.build_configurations.each do |config|
  s = config.build_settings
  s['DEVELOPMENT_TEAM']               = TEAM_ID
  s['CODE_SIGN_STYLE']                = 'Manual'
  s['CODE_SIGN_IDENTITY']             = 'Apple Distribution'
  s['PROVISIONING_PROFILE_SPECIFIER'] = 'Beyan AppStore Profile'
  s['CODE_SIGN_ENTITLEMENTS']         = 'Runner/Runner.entitlements'
end

# 2. Ses dosyalarını Runner target'ının Resources build phase'ine ekle:
runner_group = project.main_group.find_subpath('Runner', true)
%w[adhan_istanbul.caf adhan_mecca.caf adhan_medina.caf adhan_tekbir.caf adhan_istanbul.mp3 adhan_mecca.mp3 adhan_medina.mp3 adhan_tekbir.mp3].each do |audio_file|
  unless runner_group.files.any? { |f| f.path == audio_file }
    file_ref = runner_group.new_reference(audio_file)
    app_target.resources_build_phase.add_file_reference(file_ref)
  end
end

# 3. Widget Extension Target kontrol ve oluşturma
widget = project.targets.find { |t| t.name == TARGET_NAME }
unless widget
  widget = project.new_target(:app_extension, TARGET_NAME, :ios, '16.0')

  # Kaynak dosyalar
  group = project.main_group.find_subpath('IslamicAppWidget', true)
  group.set_source_tree('<group>')
  group.set_path('IslamicAppWidget')
  sources = %w[IslamicAppWidget.swift WidgetVerseData.swift].map { |f| group.new_reference(f) }
  group.new_reference('Info.plist')
  widget.add_file_references(sources)
  widget.add_system_frameworks(%w[WidgetKit SwiftUI ActivityKit Security])

  # Runner'a bağımlılık + .appex'i PlugIns klasörüne göm
  app_target.add_dependency(widget)
  embed = app_target.new_copy_files_build_phase('Embed Foundation Extensions')
  embed.dst_subfolder_spec = '13' # PlugIns
  build_file = embed.add_file_reference(widget.product_reference, true)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy', 'CodeSignOnCopy'] }

  # Flutter'ın "Thin Binary" betiğinden ÖNCE çalışmalı, aksi halde Xcode "Cycle" hatası verir
  phases = app_target.build_phases
  thin_index = phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
  phases.move(embed, thin_index) if thin_index
end

# 4. Widget Extension Build & İmzalama Ayarları
widget.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_NAME']                   = '$(TARGET_NAME)'
  s['PRODUCT_BUNDLE_IDENTIFIER']      = "#{app_bundle_id}.BeyanWidget"
  s['INFOPLIST_FILE']                 = 'IslamicAppWidget/Info.plist'
  s['GENERATE_INFOPLIST_FILE']        = 'NO'
  s['MARKETING_VERSION']              = pubspec_version
  s['CURRENT_PROJECT_VERSION']        = build_number
  s['SWIFT_VERSION']                  = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET']     = '16.0'
  s['TARGETED_DEVICE_FAMILY']         = '1,2'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['SKIP_INSTALL']                   = 'YES'
  s['DEVELOPMENT_TEAM']               = TEAM_ID
  s['CODE_SIGN_STYLE']                = 'Manual'
  s['CODE_SIGN_IDENTITY']             = 'Apple Distribution'
  s['PROVISIONING_PROFILE_SPECIFIER'] = 'Beyan Widget AppStore Profile'
  s['CODE_SIGN_ENTITLEMENTS']         = 'IslamicAppWidget/IslamicAppWidget.entitlements'
  s['LD_RUNPATH_SEARCH_PATHS']        = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

project.save
puts "Xcode projesi basariyla guncellendi (Version: #{pubspec_version}+#{build_number}, Keychain Group: aktif, Runner AppGroup: #{runner_has_app_group}, Widget AppGroup: #{widget_has_app_group})."
