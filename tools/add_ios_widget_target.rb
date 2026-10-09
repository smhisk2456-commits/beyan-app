# Beyân – iOS Widget Extension target'ını Runner.xcodeproj'a ekler ve TestFlight imzalama ayarlarını yapılandırır.
# Windows'ta Xcode olmadığı için bu betik GitHub Actions (macOS) üzerinde çalışır.
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../ios/Runner.xcodeproj', __dir__)
TARGET_NAME  = 'BeyanWidgetExtension'
TEAM_ID      = '6ABRXTHFD8'

project = Xcodeproj::Project.open(PROJECT_PATH)

app_target = project.targets.find { |t| t.name == 'Runner' } or abort('Runner target bulunamadı')
app_bundle_id = app_target.build_configurations.first.build_settings['PRODUCT_BUNDLE_IDENTIFIER']

# 1. Runner ana uygulama hedefi için imzalama ayarları
app_target.build_configurations.each do |config|
  s = config.build_settings
  s['DEVELOPMENT_TEAM']               = TEAM_ID
  s['CODE_SIGN_STYLE']                = 'Manual'
  s['CODE_SIGN_IDENTITY']             = 'Apple Distribution'
  s['PROVISIONING_PROFILE_SPECIFIER'] = 'Beyan AppStore Profile'
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
  widget.add_system_frameworks(%w[WidgetKit SwiftUI ActivityKit])

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
  s['MARKETING_VERSION']              = '1.0.0'
  s['CURRENT_PROJECT_VERSION']        = '1'
  s['SWIFT_VERSION']                  = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET']     = '16.0'
  s['TARGETED_DEVICE_FAMILY']         = '1,2'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['SKIP_INSTALL']                   = 'YES'
  s['DEVELOPMENT_TEAM']               = TEAM_ID
  s['CODE_SIGN_STYLE']                = 'Manual'
  s['CODE_SIGN_IDENTITY']             = 'Apple Distribution'
  s['PROVISIONING_PROFILE_SPECIFIER'] = 'Beyan Widget AppStore Profile'
  s['LD_RUNPATH_SEARCH_PATHS']        = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

project.save
puts "Xcode projesi basariyla guncellendi (Runner ve #{TARGET_NAME} icin Team: #{TEAM_ID}, Manual AppStore Signing aktif)."
