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

require 'urbanopt/scenario/scenario_runner_base'
require 'json'

require 'fileutils'
# require 'hash_parser'

module URBANopt
  module Scenario
    class ScenarioRunnerOSW < ScenarioRunnerBase
      ##
      # ScenarioRunnerOSW is a class to create and run SimulationFileOSWs
      ##
      def initialize; end

      ##
      # Create all OSWs for Scenario.
      ##
      # [parameters:]
      # * +scenario+ - _ScenarioBase_ - Scenario to create simulation input files for.
      # * +force_clear+ - _Bool_ - Clear Scenario before creating simulation input files.
      ##
      # [return:] _Array_ Returns array of all SimulationDirs, even those created previously, for Scenario.
      def create_simulation_files(scenario, force_clear = false)
        if force_clear
          scenario.clear
        end

        FileUtils.mkdir_p(scenario.run_dir) if !File.exist?(scenario.run_dir)
        FileUtils.rm_rf(File.join(scenario.run_dir, 'run_status.json')) if File.exist?(File.join(scenario.run_dir, 'run_status.json'))

        simulation_dirs = scenario.simulation_dirs

        simulation_dirs.each do |simulation_dir|
          if simulation_dir.out_of_date?
            puts "simulation_dir #{simulation_dir.run_dir} is out of date, regenerating input files"
            simulation_dir.create_input_files
          end
        end
        return simulation_dirs
      end

      ##
      # Create and run all SimulationFileOSW for Scenario.
      # A staged runner is implented to run buildings, then transformers then district systems.
      # - instantiate openstudio runner to run .osw files.
      # - create simulation files for this scenario.
      # - get feature_type value from in.osw files
      # - cretae 3 groups to store .osw files (+building_osws+ , +transformer_osws+ , +district_system_osws+)
      # - add each osw file to its corresponding group id +simulation_dir+ is out_of_date
      # - Run osw file groups in order and store simulation failure in a array.
      ##
      # [parameters:]
      # * +scenario+ - _ScenarioBase_ - Scenario to create and run SimulationFiles for.
      # * +force_clear+ - _Bool_ - Clear Scenario before creating SimulationFiles.
      ##
      # [return:] _Array_ Returns array of all SimulationFiles, even those created previously, for Scenario.
      def run(scenario, force_clear = false, options = {})
        # instantiate openstudio runner - use the defaults for now. If need to change then create
        # the runner.conf file (i.e. run `rake openstudio:runner:init`)
        # allow passing gemfile_path and bundle_install_path in options
        runner = OpenStudio::Extension::Runner.new(scenario.root_dir, [], options)

        # create simulation files
        simulation_dirs = create_simulation_files(scenario, force_clear)

        # osws = []
        # simulation_dirs.each do |simulation_dir|
        #   if !simulation_dir.is_a?(SimulationDirOSW)
        #     raise "ScenarioRunnerOSW does not know how to run #{simulation_dir.class}"
        #   end
        #   if simulation_dir.out_of_date?
        #     osws << simulation_dir.in_osw_path
        #   end
        # end

        # cretae 3 groups to store .osw files (+building_osws+ , +transformer_osws+ , +district_system_osws+)
        building_osws = []
        transformer_osws = []
        district_system_osws = []

        simulation_dirs.each do |simulation_dir|
          in_osw = File.read(simulation_dir.in_osw_path)
          in_osw_hash = JSON.parse(in_osw, symbolize_names: true)

          if !simulation_dir.is_a?(SimulationDirOSW)
            raise "ScenarioRunnerOSW does not know how to run #{simulation_dir.class}"
          end

          # get feature_type value from in.osw files
          feature_type = nil
          in_osw_hash[:steps].each { |x| feature_type = x[:arguments][:feature_type] if x[:arguments][:feature_type] }

          # add each osw file to its corresponding group id +simulation_dir+ is out_of_date
          if simulation_dir.out_of_date?

            if feature_type == 'Building'
              building_osws << simulation_dir.in_osw_path
            elsif feature_type == 'District System'
              district_system_osws << simulation_dir.in_osw_path
            elsif feature_type == 'Transformer'
              transformer_osws << simulation_dir.in_osw_path
            else
              raise "ScenarioRunnerOSW does not know how to run a #{feature_type} feature"
            end

          end
        end

        # Run osw groups in order and store simulation failure in an array.
        # Return simulation_dirs after running all simulations.

        # failures
        failures = []
        # run building_osws
        # building_failures = runner.run_osws(building_osws, num_parallel = Extension::NUM_PARALLEL, max_to_run = Extension::MAX_DATAPOINTS)
        building_failures = runner.run_osws(building_osws)
        failures + building_failures
        # run district_system_osws
        # district_system_failures = runner.run_osws(district_system_osws, num_parallel = Extension::NUM_PARALLEL, max_to_run = Extension::MAX_DATAPOINTS)
        district_system_failures = runner.run_osws(district_system_osws)
        failures + district_system_failures
        # run transformer_osws
        # transformer_failures = runner.run_osws(transformer_osws, num_parallel = Extension::NUM_PARALLEL, max_to_run = Extension::MAX_DATAPOINTS)
        transformer_failures = runner.run_osws(transformer_osws)
        failures + transformer_failures

        puts 'Done Running Scenario'

        # if failures.size > 0
        #   puts "DATAPOINT FAILURES: #{failures}"
        # end

        # write results to file and to command line
        get_results(scenario, simulation_dirs)

        return simulation_dirs
      end

      def get_results(scenario, simulation_dirs)
        # look for other failed datapoints (command line display)
        # also compile datapoint status for latest_run.json file
        status_arr = []
        failed_sims = []
        simulation_dirs.each do |sim_dir|
          if File.exist?(sim_dir.failed_job_path)
            failed_sims << sim_dir.run_dir.split('/')[-1]
          end
          status_arr << { "id": sim_dir.feature_id, "status": sim_dir.simulation_status, "mapper_class": sim_dir.mapper_class }
        end

        # write to file
        File.open(File.join(scenario.run_dir, 'run_status.json'), 'w') { |f| f.write JSON.pretty_generate("timestamp": Time.now.strftime('%Y-%m-%dT%k:%M:%S.%L'), "results": status_arr) }

        if !failed_sims.empty?
          puts "FAILED SIMULATION IDs: #{failed_sims.join(',')}"
        end
      end
    end
  end
end
