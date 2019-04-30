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
require "urbanopt/scenario/simulation_dir_osw"

require 'csv'
require 'fileutils'

module URBANopt
  module Scenario
    class ScenarioCSV < ScenarioBase
    
      ##
      # ScenarioCSV is a ScenarioBase which assigns a Simulation Mapper to each Feature in a FeatureFile using a simple CSV format
      # The CSV file has three columns 1) feature_id, 2) feature_name, and 3) mapper_class_name.  There is one row for each Feature.
      ##
      #  @param [String] name Human readable scenario name
      #  @param [String] root_dir Root directory for the scenario, contains Gemfile describing dependencies
      #  @param [String] run_dir Directory for simulation of this scenario, deleting run directory clears the scenario
      #  @param [URBANopt::Core::FeatureFile] feature_file FeatureFile containing features to simulate  
      #  @param [String] mapper_files_dir Directory containing all mapper class files containing MapperBase definitions
      #  @param [String] csv_file Path to CSV file assigning a MapperBase class to each feature in feature_file
      #  @param [String] num_header_rows Number of header rows to skip in CSV file  
      def initialize(name, root_dir, run_dir, feature_file, mapper_files_dir, csv_file, num_header_rows)
        super(name, root_dir, run_dir, feature_file)
        
        @mapper_files_dir = mapper_files_dir
        @csv_file = csv_file
        @num_header_rows = num_header_rows
        
        load_mapper_files
      end
      
      # Path to CSV file
      def csv_file
        @csv_file
      end
      
      # Number of header rows to skip in CSV file
      def num_header_rows
        @num_header_rows
      end
            
      # Directory containing all mapper class files
      def mapper_files_dir
        @mapper_files_dir
      end
      
      # Require all simulation mappers in mapper_files_dir
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

      def simulation_dirs
        
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
          
          features = []
          feature = feature_file.get_feature_by_id(feature_id)
          features << feature
          
          feature_names = []
          feature_names << feature_name
          
          simulation_dir = SimulationDirOSW.new(self, features, feature_names, mapper_class)

          result << simulation_dir
        end
        
        return result
      end

    end
  end
end