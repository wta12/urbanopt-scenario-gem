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


module URBANopt
  module Scenario
    class ScenarioPostProcessorBase
    
      ##
      # ScenarioPostProcessorBase post-processes a scenario to create scenario level results
      ##
      def initialize()
        
        # TODO: Rawad might need other arguments to constructor, e.g. result name, etc
        
        # TODO: Rawad this will need other members to collect the timeseries data from each data point, etc
        
      end
      
      ##
      # Assign the scenario to this result
      ##
      def set_scenario(scenario)
        @scenario = scenario
      end
      
      ##
      # Run the post processor on this scenario
      ##
      def run
        # this run method adds all the datapoints, you can extend it to do more custom stuff
        @scenario.datapoints.each do |datapoint|
          add_datapoint(datapoint)
        end
      end
      
      ##
      # Add results from a datapoint to this result
      ##
      def add_datapoint(datapoint)
        # TODO: Rawad, add results from a datapoint, this includes parsing its out.osw to find out if it ran, collecting the timeseries data, etc
      end
      
      ##
      # Save scenario result
      ##
      def save
        # TODO: Rawad, save the timeseries data to a CSV and the summary data to JSON
        
        File.open( File.join(@scenario.run_dir, 'scenario_out.json'), 'w') do |file|
          file << "{\"Results\": 1}"
        end
        
        File.open( File.join(@scenario.run_dir, 'scenario_timeseries.csv'), 'w') do |file|
          file << "1,2,3"
        end        
      end
      
    end
  end
end