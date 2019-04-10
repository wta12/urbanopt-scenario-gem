source "http://rubygems.org"

# Specify your gem's dependencies in urbanopt-geojson.gemspec
gemspec

allow_local = false

if allow_local && File.exists?('../OpenStudio-extension-gem')
  # gem 'openstudio-extension', github: 'NREL/OpenStudio-extension-gem', branch: 'develop'
  gem 'openstudio-extension', path: '../OpenStudio-extension-gem'
else
  gem 'openstudio-extension', github: 'NREL/OpenStudio-extension-gem', branch: 'develop'
end

if allow_local && File.exist?('../openstudio-common-measures-gem')
  # gem 'openstudio-common-measures', github: 'NREL/openstudio-common-measures-gem', branch: 'develop'
  gem 'openstudio-common-measures', path: '../openstudio-common-measures-gem'
else
  gem 'openstudio-common-measures', github: 'NREL/openstudio-common-measures-gem', branch: 'develop'
end

if allow_local && File.exist?('../openstudio-model-articulation-gem')
  # gem 'openstudio-model-articulation', github: 'NREL/openstudio-model-articulation-gem', branch: 'develop'
  gem 'openstudio-model-articulation', path: '../openstudio-model-articulation-gem'
else
  gem 'openstudio-model-articulation', github: 'NREL/openstudio-model-articulation-gem', branch: 'develop'
end

if allow_local && File.exist?('../urbanopt-core-gem')
  # gem 'urbanopt-core', github: 'URBANopt/urbanopt-core-gem', branch: 'develop'
  gem 'urbanopt-core', path: '../urbanopt-core-gem'
else
  gem 'urbanopt-core', github: 'URBANopt/urbanopt-core-gem', branch: 'develop'
end

# simplecov has an unneccesary dependency on native json gem, use fork that does not require this
gem 'simplecov', github: 'NREL/simplecov'