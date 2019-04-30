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
    class ScenarioDatapoint 
    
      attr_reader :scenario, :feature_id, :feature_name, :mapper_class
      
      ##
      # ScenarioDatapoint is an agnostic description of the simulation of a Feature in a Scenario
      # A Simulation Mapper will map the 
      ##
      #  @param [ScenarioBase] scenario Scenario containing this ScenarioDatapoint
      #  @param [String] feature_id Unique id of the feature for this ScenarioDatapoint
      #  @param [String] feature_name Human readable name of the feature for this ScenarioDatapoint
      #  @param [String] mapper_class Name of Ruby class used to translate feature to simulation OSW
      def initialize(scenario, feature_id, feature_name, mapper_class)
        @scenario = scenario
        @feature_id = feature_id
        @feature_name = feature_name
        @feature = scenario.feature_file.get_feature_by_id(feature_id)
        @mapper_class = mapper_class
      end
      
      def feature
        @feature 
      end
      
      def feature_type
        @feature.feature_type
      end
      
      ##
      # Return the directory that this datapoint will run in
      ##
      #  @return [String] Directory that this datapoint will run in
      def run_dir
        raise "Feature ID not set" if @feature_id.nil?
        raise "Scenario run dir not set" if @scenario.run_dir.nil?
        return File.join(@scenario.run_dir, @feature_id + '/')
      end
      
      ##
      # Return the directory that this datapoint will run in
      ##
      def clear
        dir = run_dir
        FileUtils.rm_rf(dir) if File.exists?(dir)
        FileUtils.mkdir_p(dir) if !File.exists?(dir)
      end
      
      ##
      # Create run directory and generate simulation OSW, all previous contents of directory are removed
      # The simulation OSW is created by evaluating the mapper_class's create_osw method
      ##
      #  @return [String] Path to the simulation OSW
      def create_osw
        osw = eval("#{@mapper_class}.new.create_osw(@scenario, @feature_id, @feature_name)")
        dir = run_dir
        FileUtils.rm_rf(dir) if File.exists?(dir)
        FileUtils.mkdir_p(dir) if !File.exists?(dir)
        osw_path = File.join(dir, 'in.osw')
        File.open(osw_path, 'w') do |f|
          f << JSON.pretty_generate(osw) 
          # make sure data is written to the disk one way or the other
          begin
            f.fsync
          rescue
            f.flush
          end
        end
        return osw_path
      end
      
      ##
      # Return true if the datapoint is out of date, false otherwise.  Non-existant files are out of date.
      ##
      #  @return [Boolean] True if the datapoint is out of date, false otherwise
      def out_of_date?
        dir = run_dir
        if !File.exists?(dir)
          return true
        end
        
        out_osw = File.join(dir, 'out.osw')
        if !File.exists?(out_osw)
          return true
        end
        out_osw_time = File.mtime(out_osw)
        
        # array of files that this datapoint depends on
        dependencies = []
        
        # depends on the feature file
        dependencies << scenario.feature_file.path
        
        # depends on the csv file
        dependencies << scenario.csv_file
        
        # depends on the mapper classes
        Dir.glob(File.join(scenario.mapper_files_dir, "*")).each do |f|
          dependencies << f
        end
        
        # depends on the root gemfile
        dependencies << File.join(scenario.root_dir, 'Gemfile')
        dependencies << File.join(scenario.root_dir, 'Gemfile.lock')
        
        # todo, depends on all the measures?
        
        # check if out of date
        dependencies.each do |f|
          if File.exists?(f)
            if File.mtime(f) > out_osw_time
              puts "File '#{f}' is newer than '#{out_osw}', datapoint out of date"
              return true
            end
          else
            puts "Dependency file '#{f}' does not exist"
          end
        end
        
        return false
      end
      
    end
  end
end