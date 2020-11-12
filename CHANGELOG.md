# URBANopt Scenario Gem

## Version 0.4.3
Date Range: 10/01/20 - 11/12/20

- Fixed [#161]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/161 ), updated tests to work with the added units in the json reports
- Fixed [#162]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/162 ), update spec Gemfile for new geojson version
- Fixed [#163]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/163 ), Db method
- Fixed [#165]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/165 ), Update rdoc packages
- Fixed [#166]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/166 ), use issue-closing keyword and remove period
- Fixed [#168]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/168 ), Aggregates monthly values to get the annual values.
- Fixed [#169]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/169 ), Formatting for web display of rdocs
- Fixed [#171]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/171 ), only use years after 1900 in query
- Fixed [#173]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/173 ), pin dependencies that upgraded and broke us
- Fixed [#174]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/174 ), results bug fix

## Version 0.4.2
Date Range: 09/29/20 - 09/30/20

- Fixed [#158]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/158 ), SQLite Query fix for gas consumption reporting

## Version 0.4.1
Date Range: 09/22/20 - 09/28/20

- Fixed [#156] (https://github.com/urbanopt/urbanopt-scenario-gem/issues/156), Ignore non-datapoint directories in scenario dir when creating scenario sqlite file

## Version 0.4.0
Date Range: 06/05/20 - 09/21/20

- Fixed [#138]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/138 ), Order features in scenarioData.js so that they are in the same order as in the feature file
- Fixed [#140]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/140 ), sqlite gem not found error on windows
- Fixed [#142]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/142 ), Split Reporting gem out of Scenario gem
- Fixed [#146]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/146 ), For ScenarioVisualization, add headers from the feature/scenario report without units
- Fixed [#148]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/148 ), Chore: Add TM to first mention URBANopt on LICENSE file and LICENSE section
- Fixed [#97]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/97 ), Updated PR for writing scenario outputs to sql db
- Fixed [#100]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/100 ), Bump acorn from 6.4.0 to 6.4.1 in /docs
- Fixed [#122]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/122 ), Bump websocket-extensions from 0.1.3 to 0.1.4 in /docs
- Fixed [#123]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/123 ), added location to feature reports
- Fixed [#125]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/125 ), Aggregate data from scenario reports for visualization
- Fixed [#126]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/126 ), Bump lodash from 4.17.15 to 4.17.19 in /docs
- Fixed [#127]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/127 ), Thermalstorage heine
- Fixed [#128]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/128 ), Bump elliptic from 6.5.2 to 6.5.3 in /docs
- Fixed [#129]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/129 ), bump minimist and dot-prop
- Fixed [#131]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/131 ), Adds a run_status.json
- Fixed [#132]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/132 ), Update Jenkins CI pipeline
- Fixed [#133]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/133 ), Bump prismjs from 1.19.0 to 1.21.0 in /docs
- Fixed [#134]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/134 ), Bump serialize-javascript from 2.1.2 to 3.1.0 in /docs
- Fixed [#135]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/135 ), Create visualizations for features in a scenario
- Fixed [#136]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/136 ), Bump dot-prop from 4.2.0 to 5.1.1 in /docs
- Fixed [#141]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/141 ), update sqlite dependency
- Fixed [#143]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/143 ), Uo visualization
- Fixed [#144]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/144 ), updated ice storage measures names
- Fixed [#145]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/145 ), Bump http-proxy from 1.18.0 to 1.18.1 in /docs
- Fixed [#147]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/147 ), Add unitless header values
- Fixed [#149]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/149 ), add tm symbol
- Fixed [#150]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/150 ), workaround bug when using reopt postprocessor
- Fixed [#151]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/151 ), dbot recommendations and gemspec/gemfile updates

## Version 0.3.0
Date Range: 04/01/20 - 06/04/20:

Updating to OpenStudio 3.0 and Ruby 2.5

- Fixed [#114]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/114 ), Bug fix
- Fixed [#117]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/117 ), Added utility cost outputs to reports
- Fixed [#118]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/118 ), test Jenkins using pipeline to run OpenStudio 3.0.0
- Fixed [#119]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/119 ), added timeseries outputs for heat rejection end uses
- Fixed [#120]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/120 ), Bug fix r

## Version 0.2.0


Date Range: 01/15/20 - 03/30/20:

- Fixed [#27]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/27 ), FeatureReports are not initialized with location information.
- Fixed [#38]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/38 ), Write documentation on how to configure ScenarioRunner to run multiple OSWs in parallel
- Fixed [#42]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/42 ), Scenario Report Instantiation from Hash
- Fixed [#43]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/43 ), Add timestep column to timeseries csv or add start and end timestep to feature and scenario reports
- Fixed [#46]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/46 ), add Validator class
- Fixed [#52]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/52 ), create a save as method that takes a file name
- Fixed [#54]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/54 ), Add constraint on the versions of ruby in the gemspec file
- Fixed [#56]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/56 ), Add folder for mapper csv files
- Fixed [#58]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/58 ), post process results
- Fixed [#59]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/59 ), figure out how UrbanOpt will select tariff structure for REopt
- Fixed [#65]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/65 ), make default timeseries csv for scenario; update adding feature timeseries
- Fixed [#67]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/67 ), update vuepress version
- Fixed [#70]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/70 ), updates to Scenario Gem to Support REopt Release
- Fixed [#74]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/74 ), Update copyrights
- Fixed [#75]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/75 ), make github_api a development dependency
- Fixed [#81]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/81 ), add thermal comfort results and timestamp to reports
- Fixed [#83]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/83 ), add multiple pV
- Fixed [#88]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/88 ), add units to CSV reports
- Fixed [#89]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/89 ), created Save feature report method
- Fixed [#91]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/91 ), add total_costruction_cost to reports
- Fixed [#95]( https://github.com/urbanopt/urbanopt-scenario-gem/issues/95 ), list datapoint failures
- Fixed [#98]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/98 ), add power, net power, net energy and apparent power to timeseries results
- Fixed [#101]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/101 ), fix for unit conversion when timeseries doe not exist
- Fixed [#102]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/102 ), add opendss post_processor
- Fixed [#104]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/104 ), add power distribution results to schema and reports
- Fixed [#110]( https://github.com/urbanopt/urbanopt-scenario-gem/pull/110 ), save transformer features CSV and JSON reports
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