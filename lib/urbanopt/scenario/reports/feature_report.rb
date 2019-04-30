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

require "urbanopt/scenario/reports/program"
require "urbanopt/scenario/reports/construction_costs"
require "urbanopt/scenario/reports/reporting_periods"

module URBANopt
  module Scenario
    module Reports
      class FeatureReport 
        attr_reader :id, :name, :directory_name, :feature_type, :timesteps_per_hour, :simulation_status, :program, :construction_costs, :reporting_periods
        
        # perform initialization functions
        def initialize(simulation_dir, feature, feature_name)
          @simulation_dir = simulation_dir

          @id = feature.id
          @name = feature_name
          @directory_name = simulation_dir.run_dir
          @feature_type = feature.feature_type
          @timesteps_per_hour = 1 # todo
          @simulation_status = simulation_dir.simulation_status
          @program = Program.new()
          @construction_costs = ConstructionCosts.new()
          @reporting_periods = ReportingPeriods.new()        
        end
        
        # Returns Array of FeatureReport from a simulation_dir
        def self.from_simulation_dir(simulation_dir)
        
          features = simulation_dir.features
          if features.size != 1
            raise "FeatureReport cannot support multiple features per OSW"
          end
          feature = features[0]
          feature_name = simulation_dir.feature_names[0]
          
          result = []
          result << FeatureReport.new(simulation_dir, feature, feature_name)
          return result
        end
        
        def save
          path = File.join(@simulation_dir.run_dir, 'feature.json')
        
          hash = {}
          hash[:feature] = self.to_hash

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
          result[:feature_type] = @feature_type
          result[:timesteps_per_hour] = @timesteps_per_hour
          result[:simulation_status] = @simulation_status
          result[:program] = @program.to_hash
          result[:construction_costs] = @construction_costs.to_hash
          result[:reporting_periods] = @reporting_periods.to_hash
          return result
        end
       
      end
    end
  end
end