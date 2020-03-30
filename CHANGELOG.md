# URBANopt Scenario Gem

## Version 0.2.0


Date Range: 01/15/20 - 03/30/20:

Closed Issues: 18
- Fixed [#27]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/27 ), FeatureReports are not initialized with location information. Also, location is not in the attr_accessor.
- Fixed [#38]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/38 ), Write documentation on how to configure ScenarioRunner to run multiple OSWs in parallel
- Fixed [#42]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/42 ), Scenario Report Instantiation from Hash
- Fixed [#43]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/43 ), Add timestep column to timeseries csv or add start and end timestep to feature and scenario reports
- Fixed [#46]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/46 ), add Validator class
- Fixed [#52]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/52 ), create a save as method that takes a file name
- Fixed [#53]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/53 ), Remove travis files from repo
- Fixed [#54]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/54 ), Add constraint on the versions of ruby in the gemspec file
- Fixed [#56]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/56 ), Add folder for mapper csv files
- Fixed [#57]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/57 ), Add description on the main page of repo (at the top)
- Fixed [#59]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/59 ), figure out how UrbanOpt will select tariff structure for REopt
- Fixed [#74]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/74 ), Update copyrights
- Fixed [#75]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/75 ), make github_api a development dependency
- Fixed [#82]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/82 ), Basic construction cost support
- Fixed [#84]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/84 ), Create method to save feature reports
- Fixed [#95]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/95 ), list datapoint failures
- Fixed [#103]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/103 ), OpenDSS postprocessor to aggregate outputs back into feature and scenario reports
- Fixed [#108]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/108 ), Rack version should only be specified once

Accepted Pull Requests: 35
- Fixed [#58]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/58 ), post process results
- Fixed [#65]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/65 ), make default timeseries csv for scenario; update adding feature times…
- Fixed [#67]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/67 ), update vuepress version
- Fixed [#69]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/69 ), updates
- Fixed [#70]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/70 ), updates to Scenario Gem to Support REopt Release
- Fixed [#71]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/71 ), dependency only necessary for dev. set version
- Fixed [#72]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/72 ), GH templates
- Fixed [#73]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/73 ), move contributing guidelines to root
- Fixed [#76]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/76 ), update package-lock file
- Fixed [#77]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/77 ), update copyright dates to include 2020
- Fixed [#78]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/78 ), delete unused travis file
- Fixed [#79]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/79 ), fix rack version temporarily to work with Ruby 2.2.4
- Fixed [#80]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/80 ), starting db method
- Fixed [#81]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/81 ), add thermal comfort results and timestamp to reports
- Fixed [#83]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/83 ), add multiple pV
- Fixed [#85]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/85 ), add function to save scenario-level results to sql file
- Fixed [#86]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/86 ), gemspec update
- Fixed [#87]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/87 ), update Jenkinsfile for ruby 2.2.4 and bundler 1.x support
- Fixed [#88]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/88 ), add units to CSV reports
- Fixed [#89]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/89 ), created Save feature report method
- Fixed [#91]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/91 ), add total_costruction_cost to reports
- Fixed [#92]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/92 ), revert "Add function to save scenario-level results to sql file"
- Fixed [#93]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/93 ), specify Ruby version
- Fixed [#94]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/94 ), updates to create_scenario_db_file() method and Gemfile
- Fixed [#96]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/96 ), list failed runs after scenario runs
- Fixed [#98]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/98 ), add power, net power, net energy and apparent power to timeseries results
- Fixed [#99]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/99 ), prep for pre-release
- Fixed [#101]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/101 ), fix for unit conversion when timeseries doe not exist
- Fixed [#102]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/102 ), add opendss post_processor
- Fixed [#104]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/104 ), add power distribution results to schema and reports
- Fixed [#105]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/105 ), update Multiplepv
- Fixed [#106]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/106 ), bug fixes
- Fixed [#107]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/107 ), bug fixes to timeseries csv
- Fixed [#109]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/109 ), only specify Rack version once
- Fixed [#110]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/110 ), save transformer features CSV and JSON reports
- Fixed [#111]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/111 ), prep for 0.2.0 release
- Fixed [#112]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/112 ), added additional timeseries results to CSV reports


## Version 0.1.1

Date Range: 10/16/19 - 01/14/20

Accepted Pull Requests:
- Fixed [#34]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/34 ), Post process
- Fixed [#44]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/44 ), reopt integrations
- Fixed [#47]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/47 ), Use runner.conf for run options
- Fixed [#48]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/48 ), Bump mixin-deep from 1.3.1 to 1.3.2 in /docs
- Fixed [#49]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/49 ), Bump lodash from 4.17.11 to 4.17.15 in /docs
- Fixed [#50]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/50 ), Bump lodash.template from 4.4.0 to 4.5.0 in /docs
- Fixed [#51]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/51 ), Der
- Fixed [#61]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/61 ), GitHub security
- Fixed [#62]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/62 ), Update issue templates
- Fixed [#64]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/64 ), update dependency versions for security

## Version 0.1.0