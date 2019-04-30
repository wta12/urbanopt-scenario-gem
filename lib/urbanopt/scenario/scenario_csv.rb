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

require "urbanopt/scenario/scenario_base"
require "urbanopt/scenario/scenario_datapoint"

require 'csv'
require 'fileutils'

module URBANopt
  module Scenario
    class ScenarioCSV < ScenarioBase
    
      def initialize(name, root_dir, run_dir, feature_file, mapper_files_dir, csv_file, num_header_rows)
        super(name, root_dir, run_dir, feature_file, mapper_files_dir)
        
        @csv_file = csv_file
        @num_header_rows = num_header_rows
      end
      
      def csv_file
        @csv_file
      end
      
      def num_header_rows
        @num_header_rows
      end
      
      def datapoints
        
        # DLM: TODO use HeaderConverters from CSV module
        
        rows_skipped = 0
        result = []
        CSV.foreach(@csv_file) do |row|
          
          if rows_skipped < @num_header_rows
            rows_skipped += 1
            next
          end
          
          break if row[0].nil?
          
          feature_id = row[0].chomp
          feature_name = row[1].chomp
          mapper_class = row[2].chomp
          
          datapoint = ScenarioDatapoint.new(self, feature_id, feature_name, mapper_class)

          result << datapoint
        end
        
        return result
      end

    end
  end
end