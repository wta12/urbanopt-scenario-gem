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

require_relative '../spec_helper'
require_relative '../files/example_feature_file'

RSpec.describe URBANopt::Scenario do
  it 'has a version number' do
    expect(URBANopt::Scenario::VERSION).not_to be nil
  end
  
  it 'can run a scenario' do
  
    name = 'Example Scenario'
    run_dir = File.join(File.dirname(__FILE__), '../test/example_scenario/')
    feature_file_path = File.join(File.dirname(__FILE__), '../files/example_feature_file.json')
    mapper_files_dir = File.join(File.dirname(__FILE__), '../files/mappers/')
    csv_file = File.join(File.dirname(__FILE__), '../files/example_scenario.csv')
    num_header_rows = 1
    root_dir = File.join(File.dirname(__FILE__), '../../')
      
    feature_file = ExampleFeatureFile.new(feature_file_path)
    expect(feature_file.features.size).to eq(3)
    expect(feature_file.get_feature_by_id('1')).not_to be_nil
    expect(feature_file.get_feature_by_id('2')).not_to be_nil
    expect(feature_file.get_feature_by_id('3')).not_to be_nil
    expect(feature_file.get_feature_by_id('4')).to be_nil
    
    # create a new ScenarioCSV, we could create many of these in a project
    scenario = URBANopt::Scenario::ScenarioCSV.new(name, root_dir, run_dir, feature_file, mapper_files_dir, csv_file, num_header_rows)
    expect(scenario.name).to eq(name)
    expect(scenario.root_dir).to eq(root_dir)
    expect(scenario.run_dir).to eq(run_dir)
    expect(scenario.feature_file.path).to eq(feature_file.path)
    expect(scenario.mapper_files_dir).to eq(mapper_files_dir)
    expect(scenario.csv_file).to eq(csv_file)
    expect(scenario.num_header_rows).to eq(1)
    
    # Rawad: set clear_results to be false if you want the tests to run faster
    clear_results = false
    scenario.clear if clear_results 
    
    simulation_dirs = scenario.simulation_dirs
    expect(simulation_dirs.size).to eq(3)
    expect(simulation_dirs[0].features.size).to eq(1)
    expect(simulation_dirs[0].feature_names.size).to eq(1)
    expect(simulation_dirs[0].features[0].id).to eq('1')
    expect(simulation_dirs[0].feature_names[0]).to eq('Building 1')
    expect(simulation_dirs[0].mapper_class).to eq('URBANopt::Scenario::TestMapper1')
    expect(simulation_dirs[0].run_dir).to eq(File.join(run_dir, '1/'))
    
    if clear_results
      expect(File.exists?(simulation_dirs[0].run_dir)).to be false
      expect(File.exists?(simulation_dirs[1].run_dir)).to be false
      expect(File.exists?(simulation_dirs[2].run_dir)).to be false
    end
    
    # create a ScenarioRunnerOSW to run the ScenarioCSV
    scenario_runner = URBANopt::Scenario::ScenarioRunnerOSW.new
    
    scenario_runner.create_simulation_files(scenario, clear_results)
    expect(File.exists?(simulation_dirs[0].run_dir)).to be true
    expect(File.exists?(simulation_dirs[1].run_dir)).to be true
    expect(File.exists?(simulation_dirs[2].run_dir)).to be true
    
    simulation_dirs = scenario_runner.run(scenario)
    if clear_results
      expect(simulation_dirs.size).to eq(3)
      expect(simulation_dirs[0].in_osw_path).to eq(File.join(run_dir, '1/in.osw'))
      expect(simulation_dirs[1].in_osw_path).to eq(File.join(run_dir, '2/in.osw'))
      expect(simulation_dirs[2].in_osw_path).to eq(File.join(run_dir, '3/in.osw'))
    end
    
    failures = []
    simulation_dirs.each do |simulation_dir|
      run_dir = simulation_dir.run_dir
      simulation_status = simulation_dir.simulation_status
      puts "run_dir = #{run_dir}, simulation_status = #{simulation_status}"
      if simulation_dir.simulation_status != 'Complete'
        failures << run_dir
      end
    end
    
    expect(failures).to be_empty, "the following directories failed to run [#{failures.join(', ')}]"
    
    default_post_processor = URBANopt::Scenario::ScenarioDefaultPostProcessor.new(scenario)
    scenario_result = default_post_processor.run
    scenario_result.save
    
    # TODO: Rawad, add test assertions on scenario_result
  end


end
