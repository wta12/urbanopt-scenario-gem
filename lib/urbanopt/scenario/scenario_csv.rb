# *********************************************************************************
# URBANopt™, Copyright (c) 2019-2021, Alliance for Sustainable Energy, LLC, and other
# contributors. All rights reserved.

# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:

# Redistributions of source code must retain the above copyright notice, this list
# of conditions and the following disclaimer.

# Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution.

# Neither the name of the copyright holder nor the names of its contributors may be
# used to endorse or promote products derived from this software without specific
# prior written permission.

# Redistribution of this software, without modification, must refer to the software
# by the same designation. Redistribution of a modified version of this software
# (i) may not refer to the modified version by the same designation, or by any
# confusingly similar designation, and (ii) must refer to the underlying software
# originally provided by Alliance as “URBANopt”. Except to comply with the foregoing,
# the term “URBANopt”, or any confusingly similar designation may not be used to
# refer to any modified version of this software or any modified version of the
# underlying software originally provided by Alliance without the prior written
# consent of Alliance.

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
# *********************************************************************************

require 'urbanopt/scenario/scenario_base'
require 'urbanopt/scenario/simulation_dir_osw'

require 'csv'
require 'fileutils'

module URBANopt
  module Scenario
    class ScenarioCSV < ScenarioBase
      ##
      # ScenarioCSV is a ScenarioBase which assigns a Simulation Mapper to each Feature in a FeatureFile using a simple CSV format.
      # The CSV file has three columns 1) feature_id, 2) feature_name, and 3) mapper_class_name.  There is one row for each Feature.
      ##
      # [parameters:]
      # * +name+ - _String_ - Human readable scenario name.
      # * +root_dir+ - _String_ - Root directory for the scenario, contains Gemfile describing dependencies.
      # * +run_dir+ - _String_ - Directory for simulation of this scenario, deleting run directory clears the scenario.
      # * +feature_file+ - _URBANopt::Core::FeatureFile_ - FeatureFile containing features to simulate.
      # * +mapper_files_dir+ - _String_ - Directory containing all mapper class files containing MapperBase definitions.
      # * +csv_file+ - _String_ - Path to CSV file assigning a MapperBase class to each feature in feature_file.
      # * +num_header_rows+ - _String_ - Number of header rows to skip in CSV file.
      def initialize(name, root_dir, run_dir, feature_file, mapper_files_dir, csv_file, num_header_rows)
        super(name, root_dir, run_dir, feature_file)
        @mapper_files_dir = mapper_files_dir
        @csv_file = csv_file
        @num_header_rows = num_header_rows

        @@logger ||= URBANopt::Scenario.logger

        load_mapper_files
      end

      # Path to CSV file
      attr_reader :csv_file #:nodoc:

      # Number of header rows to skip in CSV file
      attr_reader :num_header_rows #:nodoc:

      # Directory containing all mapper class files
      attr_reader :mapper_files_dir #:nodoc:

      # Require all simulation mappers in mapper_files_dir
      def load_mapper_files
        dirs = Dir.glob(File.join(@mapper_files_dir, '/*.rb'))
        # order is not guaranteed...attempt to add Baseline first, then High Efficiency
        ordered_dirs = []
        bindex = dirs.find_index { |i| i.include? 'Baseline.rb' }
        if bindex
          ordered_dirs << dirs[bindex]
          dirs.delete_at(bindex)
        end
        hindex = dirs.find_index { |i| i.include? 'HighEfficiency.rb' }
        if hindex
          ordered_dirs << dirs[hindex] if hindex
          dirs.delete_at(hindex)
        end
        # then the rest
        ordered_dirs += dirs

        ordered_dirs.each do |f|
          require(f)
        rescue LoadError => e
          @@logger.error(e.message)
          raise
        end
      end

      # Gets all the simulation directories
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

          # gets +feature_id+ , +feature_name+ and +mapper_class+ from csv_file
          feature_id = row[0].chomp
          feature_name = row[1].chomp
          mapper_class = row[2].chomp

          # gets +features+ from the feature_file.
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
