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

require 'urbanopt/scenario/reports/feature_report'
require 'urbanopt/scenario/reports/program'
require 'urbanopt/scenario/reports/construction_costs'
require 'urbanopt/scenario/reports/reporting_periods'

require 'json'

module URBANopt
  module Scenario
    module Reports
      class ScenarioReport 
        
        # perform initialization functions
        def initialize(scenario)
          @scenario = scenario
          
          @id = scenario.name
          @name = scenario.name
          @directory_name = scenario.run_dir
          @timesteps_per_hour = nil # unknown
          @number_of_not_started_simulations = 0
          @number_of_started_simulations = 0
          @number_of_complete_simulations = 0
          @number_of_failed_simulations = 0
          @program = Program.new
          @construction_costs = ConstructionCosts.new
          @reporting_periods = ReportingPeriods.new
          @features = []
        end
        
        def save()
        
          path = File.join(@scenario.run_dir, 'scenario.json')
          
          hash = {}
          hash[:scenario] = self.to_hash
          hash[:features] = []
          @features.each do |feature|
            hash[:features] << feature.to_hash
          end
          
          File.open(path, 'w') do |f|
            f.puts JSON::fast_generate(hash)
            # make sure data is written to the disk one way or the other
            begin
              f.fsync
            rescue
              f.flush
            end
          end
          
          return true
        end
        
        def to_hash
          result = {}
          result[:id] = @id
          result[:name] = @name
          result[:directory_name] = @directory_name
          result[:timesteps_per_hour] = @timesteps_per_hour
          result[:number_of_not_started_simulations] = @number_of_not_started_simulations
          result[:number_of_started_simulations] = @number_of_started_simulations
          result[:number_of_complete_simulations] = @number_of_complete_simulations
          result[:number_of_failed_simulations] = @number_of_failed_simulations
          result[:program] = @program.to_hash
          result[:construction_costs] = @construction_costs.to_hash
          result[:reporting_periods] = @reporting_periods.to_hash
          return result
        end
        
        def add_feature_report(feature)
          
          if @timesteps_per_hour.nil?
            @timesteps_per_hour = feature.timesteps_per_hour
          else
            # check that this feature was simulated with required timesteps per hour
            if feature.timesteps_per_hour != @timesteps_per_hour
              raise "Feature timesteps_per_hour = '#{feature.timesteps_per_hour}' does not match scenario timesteps_per_hour '#{@timesteps_per_hour}'"
            end
          end
          
          # check that we have not already added this feature
          id = feature.id
          @features.each do |existing_feature|
            if existing_feature.id == id
              raise "Feature with id = '#{id}' has already been added"
            end
          end
          
          # check feature simulation status
          if feature.simulation_status == 'Not Started'
            @number_of_not_started_simulations +=1 
          elsif feature.simulation_status == 'Started'
            @number_of_started_simulations +=1 
          elsif feature.simulation_status == 'Complete'
            @number_of_complete_simulations +=1 
          elsif feature.simulation_status == 'Failed'
            @number_of_failed_simulations +=1 
          else 
            raise "Unknown feature simulation_status = '#{feature.simulation_status}'"
          end
          
          # merge program information
          @program.add_program(feature.program)
          
          # merge construction costs information
          @construction_costs.add_construction_costs(feature.construction_costs)
          
          # merge reporting periods information
          @reporting_periods.add_reporting_periods(feature.reporting_periods)
          
          # add feature
          @features << feature
        end
        
       
      end
    end
  end
end