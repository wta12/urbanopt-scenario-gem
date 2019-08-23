#*********************************************************************************
# URBANopt, Copyright (c) 2019, Alliance for Sustainable Energy, LLC, and other 
# contributors. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list 
# of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright notice, this 
# list of conditions and the following disclaimer in the documentation and/or other 
# materials provided with the distribution.
# 
# Neither the name of the copyright holder nor the names of its contributors may be 
# used to endorse or promote products derived from this software without specific 
# prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
# OF THE POSSIBILITY OF SUCH DAMAGE.
#*********************************************************************************

require 'urbanopt/scenario/default_reports/construction_cost'
require 'urbanopt/scenario/default_reports/feature_report'
require 'urbanopt/scenario/default_reports/program'
require 'urbanopt/scenario/default_reports/reporting_period'
require 'urbanopt/scenario/default_reports/timeseries_csv'
require 'urbanopt/scenario/default_reports/extension'
require 'json-schema'

require 'json'
require 'pathname'



module URBANopt
  module Scenario
    module DefaultReports
    
      ## 
      # ScenarioReport can generate two types of reports from a scenario. 
      # The first is a JSON format saved to 'default_scenario_report.json'.
      # The second is a CSV format saved to 'default_scenario_report.csv'.
      ##
      class ScenarioReport 
        attr_accessor :id, :name, :directory_name, :timesteps_per_hour, :number_of_not_started_simulations, :number_of_started_simulations, :number_of_complete_simulations, 
                      :number_of_failed_simulations, :timeseries_csv, :location,  :program, :construction_costs, :reporting_periods, :feature_reports
        

        
        ##
        # Create a ScenarioReport from a derivative of ScenarioBase (e.g. ScenarioCSV).
        # The ScenarioBase should have been run at this point with FeatureReports generated.
        ##
        #  @param [ScenarioBase] scenario Scenario to generate results for
        def self.from_scenario_base(scenario_csv)
          result = ScenarioReport.new()

          #get all the features from the scenario base, create a feature report for each, accumulate the feature reports
          scenario_csv.simulation_dirs.each do |simulation_dir|
            feature_reports = FeatureReport.from_simulation_dir(simulation_dir)
            

            feature_reports.each do |feature_report|
              result.add_feature_report(feature_report)
            end
          end
          
          @@scenario_csv = scenario_csv
        
          return result
        end
        
        ##
        # Each ScenarioReport object corresponds to a single Scenario.
        ##
        #  @param [ScenarioBase] scenario Scenario to generate results for
        def initialize(hash = {})
          puts " scenario report hash is == #{hash}"
          
          hash.delete_if {|k,v| v.nil?}
          hash = defaults.merge(hash)
        
          

          @id = hash[:id]
          @name = hash[:name]
          @directory_name = hash[:directory_name]
          @timesteps_per_hour = hash[:timesteps_per_hour]
          @number_of_not_started_simulations = hash[:number_of_not_started_simulations]
          @number_of_started_simulations = hash[:number_of_started_simulations]
          @number_of_complete_simulations = hash[:number_of_complete_simulations]
          @number_of_failed_simulations = hash[:number_of_failed_simulations]
          @timeseries_csv = TimeseriesCSV.new(hash[:timeseries_csv])
          @location = hash[:location]
          @program = Program.new(hash[:program])
          @construction_costs = hash[:construction_costs]
          @reporting_periods = hash[:reporting_periods]
          @feature_reports = hash[:feature_reports]

          @scenario = hash

          #@scenario_csv = @@scenario_csv
          #puts "scenario_csv is = =====  == #{@scenario_csv}"
          # @id = scenario.name
          # @name = scenario.name
          # @directory_name = scenario.run_dir
          # puts "SCENARIO RUN DIRECTORY IS #{scenario.class}"
          # @timesteps_per_hour = nil # unknown
          # @number_of_not_started_simulations = 0
          # @number_of_started_simulations = 0
          # @number_of_complete_simulations = 0
          # @number_of_failed_simulations = 0
          # @timeseries_csv = TimeseriesCSV.new
          # @location = nil
          # @program = Program.new
          # @construction_costs = []
          # @reporting_periods = []       
          # @feature_reports = []
                   
          # initialize class variable @@extension only once
          @@extension ||= Extension.new
          @@schema ||= @@extension.schema

        end

        def defaults  
          hash = {}
          hash[:id] = nil.to_s #scenario_csv.name
          hash[:name] = nil.to_s #scenario_csv.name
          hash[:directory_name] = nil.to_s #scenario_csv.run_dir
          hash[:timesteps_per_hour] = nil #unknown
          hash[:number_of_not_started_simulations] = 0
          hash[:number_of_started_simulations] = 0
          hash[:number_of_complete_simulations] = 0
          hash[:number_of_failed_simulations] = 0
          hash[:timeseries_csv] = TimeseriesCSV.new.to_hash
          hash[:location] = nil
          hash[:program] = Program.new.to_hash
          hash[:construction_costs] = []
          hash[:reporting_periods] = []
          hash[:feature_reports] = []
          return hash
        end

        def json_path
          puts "@@RUN _DIR IS == #{@@scenario_csv.run_dir}"
          File.join(@@scenario_csv.run_dir, 'default_scenario_report.json')
        end
        
        def csv_path
          File.join(@@scenario_csv.run_dir, 'default_scenario_report.csv')
        end
        
        ##
        # Save the 'default_feature_report.json' and 'default_scenario_report.csv' files
        ##
        def save()
          
          hash = {}
          hash[:scenario_report] = self.to_hash
          hash[:feature_reports] = []
          @feature_reports.each do |feature_report|
            hash[:feature_reports] << feature_report.to_hash
          end
          
          File.open(json_path, 'w') do |f|
            f.puts JSON::pretty_generate(hash)
            # make sure data is written to the disk one way or the other
            begin
              f.fsync
            rescue
              f.flush
            end
          end
 
          # save the csv data
          timeseries_csv.save_data(csv_path)
          
          return true
        end
        
        ##
        # Convert to a Hash equivalent for JSON serialization
        ##
        def to_hash
          result = {}
          result[:id] = @@scenario_csv.name
          result[:name] = @@scenario_csv.name
          result[:directory_name] = @@scenario_csv.run_dir
          result[:timesteps_per_hour] = @timesteps_per_hour
          result[:number_of_not_started_simulations] = @number_of_not_started_simulations
          result[:number_of_started_simulations] = @number_of_started_simulations
          result[:number_of_complete_simulations] = @number_of_complete_simulations
          result[:number_of_failed_simulations] = @number_of_failed_simulations
          result[:timeseries_csv] = @timeseries_csv.to_hash
          result[:location] = @location
          result[:program] = @program.to_hash
          
          result[:construction_costs] = []
          @construction_costs.each{|cc| result[:construction_costs] << cc.to_hash}
          
          result[:reporting_periods] = []
          @reporting_periods.each{|rp| result[:reporting_periods] << rp.to_hash}

          # validate scenario_report properties against schema
          if @@extension.validate(@@schema[:definitions][:ScenarioReport][:properties],result).any?
            raise "scenario_report properties does not match schema: #{@@extension.validate(@@schema[:definitions][:ScenarioReport][:properties],result)}"
          end 

          return result
        end
        
        def add_feature_report(feature_report)
          #puts " START ADDING FEATURE REPORT"
          if @timesteps_per_hour.nil?
            @timesteps_per_hour = feature_report.timesteps_per_hour
          else
            # check that this feature_report was simulated with required timesteps per hour
            if feature_report.timesteps_per_hour != @timesteps_per_hour
              raise "FeatureReport timesteps_per_hour = '#{feature_report.timesteps_per_hour}' does not match scenario timesteps_per_hour '#{@timesteps_per_hour}'"
            end
          end
          
          # check that we have not already added this feature
          id = feature_report.id
          @feature_reports.each do |existing_feature_report|
            if existing_feature_report.id == id
              raise "FeatureReport with id = '#{id}' has already been added"
            end
          end
          
          # check feature simulation status
          if feature_report.simulation_status == 'Not Started'
            @number_of_not_started_simulations +=1 
          elsif feature_report.simulation_status == 'Started'
            @number_of_started_simulations +=1 
          elsif feature_report.simulation_status == 'Complete'
            @number_of_complete_simulations +=1 
          elsif feature_report.simulation_status == 'Failed'
            @number_of_failed_simulations +=1 
          else 
            raise "Unknown feature_report simulation_status = '#{feature_report.simulation_status}'"
          end
          
          # merge timeseries_csv information
          @timeseries_csv.add_timeseries_csv(feature_report.timeseries_csv)
          
          @timeseries_csv.run_dir_name(@directory_name)
          
          # merge program information
          @program.add_program(feature_report.program)
          
          
          # merge construction costs information
          @construction_costs = ConstructionCost.merge_construction_costs(@construction_costs, feature_report.construction_costs)
          
          
          # merge reporting periods information
          @reporting_periods = ReportingPeriod.merge_reporting_periods(@reporting_periods, feature_report.reporting_periods)
          
          
          # add feature_report
          @feature_reports << feature_report

          # assign scenario location to the location of the first feature
          @location = feature_reports[0].location

        end
        
       
      end
    end
  end
end