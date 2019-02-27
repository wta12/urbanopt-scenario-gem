########################################################################################################################
#  openstudio(R), Copyright (c) 2008-2019, Alliance for Sustainable Energy, LLC. All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
#  following conditions are met:
#
#  (1) Redistributions of source code must retain the above copyright notice, this list of conditions and the following
#  disclaimer.
#
#  (2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#  following disclaimer in the documentation and/or other materials provided with the distribution.
#
#  (3) Neither the name of the copyright holder nor the names of any contributors may be used to endorse or promote
#  products derived from this software without specific prior written permission from the respective party.
#
#  (4) Other than as required in clauses (1) and (2), distributions in any form of modifications or other derivative
#  works may not use the "openstudio" trademark, "OS", "os", or any other confusingly similar designation without
#  specific prior written permission from Alliance for Sustainable Energy, LLC.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER, THE UNITED STATES GOVERNMENT, OR ANY CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
#  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
########################################################################################################################

require "urbanopt/scenario/scenario_base"
require "urbanopt/scenario/scenario_datapoint"

require 'csv'
require 'fileutils'

module URBANopt
  module Scenario
    class ScenarioCSV < ScenarioBase
    
      attr_accessor :csv_file, :mapper_files_dir, :run_dir, :num_header_rows
      
      def initialize(name, root_dir, csv_file, mapper_files_dir, run_dir)
        super()
        @name = name
        @root_dir = root_dir
        
        @csv_file = csv_file
        @mapper_files_dir = mapper_files_dir
        @run_dir = run_dir
        
        @num_header_rows = 0
        
        load_mapper_files
      end
      
      def clear
        Dir.glob(File.join(@run_dir, '/*')).each do |f|
          FileUtils.rm_rf(f)
        end
      end
      
      def load_mapper_files
        Dir.glob(File.join(@mapper_files_dir, '/*.rb')).each do |f|
          begin
            require(f)
          rescue LoadError => e
            puts e.message
            raise         
          end
        end
      end
      
      # return an array of ScenarioDatapoint objects from the CSV
      def read_csv
        
        # DLM: TODO use HeaderConverters
        
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
          
          datapoint = ScenarioDatapoint.new(self)
          datapoint.feature_id = feature_id
          datapoint.feature_name = feature_name
          datapoint.mapper_class = mapper_class
          
          result << datapoint
        end
        
        return result
      end
      
      
      def create_osws
        
        clear
        
        FileUtils.mkdir_p(@run_dir) if !File.exists?(@run_dir)
        
        datapoints = read_csv
        
        osws = []
        datapoints.each do |datapoint|
          osws << datapoint.create_osw
        end

        return osws
      end
      
      def run
        runner = OpenStudio::Extension::Runner.new(@root_dir)
        
        osws = create_osws
        
        failures = runner.run_osws(osws)
        
        return failures
      end

    end
  end
end