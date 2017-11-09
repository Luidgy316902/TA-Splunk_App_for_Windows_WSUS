require 'github_changelog_generator/task'
require 'inifile'

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  # config.since_tag = '0.1.14'
  app_conf = IniFile.load('./default/app.conf')
  config.future_release = 'v' + app_conf['launcher']['version']
  config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file.\nThis project follows semver to help clients understand the impact of updates/changes.  Find out more at http://semver.org."
end
