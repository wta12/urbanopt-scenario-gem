source 'http://rubygems.org'

# Specify your gem's dependencies in urbanopt-scenario-gem.gemspec
gemspec

# Local gems are useful when developing and integrating the various dependencies.
# To favor the use of local gems, set the following environment variable:
#   Mac: export FAVOR_LOCAL_GEMS=1
#   Windows: set FAVOR_LOCAL_GEMS=1
# Note that if allow_local is true, but the gem is not found locally, then it will
# checkout the latest version (develop) from github.
allow_local = ENV['FAVOR_LOCAL_GEMS']

# Uncomment the extension gem if you need to test local development versions. Otherwise
# is is included in the model articulation gem.
#
# if allow_local && File.exist?('../OpenStudio-extension-gem')
#   gem 'openstudio-extension', path: '../OpenStudio-extension-gem'
# elsif allow_local
#   gem 'openstudio-extension', github: 'NREL/OpenStudio-extension-gem', branch: 'develop'
# end

# TEMPORARY CHANGE
# gem 'openstudio-extension', github: 'NREL/OpenStudio-extension-gem', branch: 'develop'

# if allow_local && File.exist?('../openstudio-common-measures-gem')
#   gem 'openstudio-common-measures', path: '../openstudio-common-measures-gem'
# elsif allow_local
#   gem 'openstudio-common-measures', github: 'NREL/openstudio-common-measures-gem', branch: 'develop'
# end

if allow_local && File.exist?('../openstudio-model-articulation-gem')
  gem 'openstudio-model-articulation', path: '../openstudio-model-articulation-gem'
else
  gem 'openstudio-model-articulation', github: 'NREL/openstudio-model-articulation-gem', branch: 'develop'
end

if allow_local && File.exist?('../urbanopt-core-gem')
  gem 'urbanopt-core', path: '../urbanopt-core-gem'
else
  gem 'urbanopt-core', github: 'URBANopt/urbanopt-core-gem', branch: 'develop'
end

#if allow_local && File.exist?('../urbanopt-reporting-gem')
#  gem 'urbanopt-reporting', path: '../urbanopt-reporting-gem'
#elsif allow_local
gem 'urbanopt-reporting', github: 'URBANopt/urbanopt-reporting-gem', branch: 'develop'
#end

# if allow_local && File.exist?('../openstudio-load-flexibility-measures-gem')
#   gem 'openstudio-load-flexibility-measures', path: '../openstudio-load-flexibility-measures-gem'
# else
#   gem 'openstudio-load-flexibility-measures', github: 'NREL/openstudio-load-flexibility-measures-gem', branch: 'master'
# end
