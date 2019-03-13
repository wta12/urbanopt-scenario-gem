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
    
      attr_accessor :csv_file, :mapper_files_dir, :run_dir, :num_header_rows
      
      ##
      # ScenarioCSV defines a scenario by assigning a Ruby MapperBase to 
      ##
      #  @param [String] name Name of this scenario
      #  @param [String] root_dir Directory that includes Gemfile for gems used in this scenario
      #  @param [String] csv_file Path to a CSV file that assigns Ruby MapperBase to each feature in the scenario
      #  @param [String] mapper_files_dir Directory containing Ruby files which define MapperBase used in the scenario 
      #  @param [String] run_dir Directory that all ScenarioDatapoints will run in and will contain scenario level results
      def initialize(name, root_dir, csv_file, mapper_files_dir, run_dir)
        super()
        @name = name
        @root_dir = root_dir
        
        @csv_file = csv_file
        @mapper_files_dir = mapper_files_dir
        @run_dir = run_dir
        
        @instance_lock = Mutex.new
        @datapoints = nil
        
        @num_header_rows = 0
        
        load_mapper_files
      end
      
      ##
      # Delete all content in the run_dir
      ##
      def clear
        Dir.glob(File.join(@run_dir, '/*')).each do |f|
          FileUtils.rm_rf(f)
        end
      end
      
      ##
      # Remove all folders in run_dir that do not correspond to a datapoint
      ##
      #  @return [Array] Array of removed directories
      def clean
        dirs = run_dirs
        
        result = []
        Dir.glob(File.join(@run_dir, '/*')).each do |f|
          if !dirs.include?(f)
            FileUtils.rm_rf(f)
            result << f
          end
        end
        return f
      end      
      
      ##
      # Require all Ruby files in the mapper_files_dir
      ##
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
      
      ##
      # Return array of ScenarioDatapoints, will read from CSV if not already read
      ##
      #  @return [Array] Array of ScenarioDatapoints
      def datapoints
        @instance_lock.synchronize do
          if @datapoints.nil?
            @datapoints = read_csv
          end
        end
        return @datapoints
      end
      
      ##
      # Create OSWs for all out of date datapoints, if you need to create all OSWS call clear first
      ##
      #  @return [Array] Array of newly created datapoint OSWs
      def create_osws
        
        FileUtils.mkdir_p(@run_dir) if !File.exists?(@run_dir)
        
        osws = []
        datapoints.each do |datapoint|
          if datapoint.out_of_date?
            osws << datapoint.create_osw
          end
        end

        return osws
      end
      
      ##
      # Return run directories for all ScenarioDatapoints
      ##
      #  @return [Array] Array of run directories
      def run_dirs

        result = []
        datapoints.each do |datapoint|
          result << datapoint.run_dir
        end

        return result
      end
      
      ##
      # Runs all out of date datapoints, if you want to run all datapoints call clear first
      ##
      #  @return [Array] Array of failed simulations
      def run
        runner = OpenStudio::Extension::Runner.new(@root_dir)

        osws = create_osws
        
        failures = runner.run_osws(osws)
        
        return failures
      end
      
      ##
      # Clears all results, creates simulation OSWs for all datapoints, and runs simulations
      ##
      #  @return [Array] Array of failed simulations
      def post_process

        #TODO: Rawad fill in here
        
        # create a new ScenarioResult object
        result = ScenarioResult.new
        
        # loop over each datapoint and get that datapoints result files
        datapoints.each do |datapoint|
          # add those results to the ScenarioResult
          result.add(datapoint)
        end

        # save the ScenarioResult
        result.save
        
        return result
      end
      
      private
      
      ##
      # Parse the CSV file and return array of ScenarioDatapoints
      ##
      #  @return [Array] Array of ScenarioDatapoints
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
          
          datapoint = ScenarioDatapoint.new(self, feature_id, feature_name, mapper_class)
          
          result << datapoint
        end
        
        return result
      end
      
    end
  end
end