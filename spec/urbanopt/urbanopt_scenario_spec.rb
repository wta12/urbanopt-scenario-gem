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

RSpec.describe URBANopt::Scenario do
  it 'has a version number' do
    expect(URBANopt::Scenario::VERSION).not_to be nil
  end
  
  it 'can run a scenario' do
    name = 'Example Scenario'
    root_dir = File.join(File.dirname(__FILE__), '../../')
    csv_file = File.join(File.dirname(__FILE__), '../files/example_scenario.csv')
    geometry_file = File.join(File.dirname(__FILE__), '../files/example_geometry.json')
    mapper_files_dir = File.join(File.dirname(__FILE__), '../files/mappers/')
    run_dir = File.join(File.dirname(__FILE__), '../test/example_scenario/')
    
    # create a new ScenarioCSV, we could create many of these
    scenario = URBANopt::Scenario::ScenarioCSV.new(name, root_dir, csv_file, mapper_files_dir, run_dir)
    scenario.geometry_file = geometry_file
    scenario.num_header_rows = 1
    
    expect(scenario.name).to eq(name)
    expect(scenario.root_dir).to eq(root_dir)
    expect(scenario.csv_file).to eq(csv_file)
    expect(scenario.mapper_files_dir).to eq(mapper_files_dir)
    expect(scenario.run_dir).to eq(run_dir)
    expect(scenario.num_header_rows).to eq(1)
    
    scenario.clear
    
    datapoints = scenario.read_csv
    expect(datapoints.size).to eq(3)
    expect(datapoints[0].feature_id).to eq('1')
    expect(datapoints[0].feature_name).to eq('Building 1')
    expect(datapoints[0].mapper_class).to eq('URBANopt::Scenario::TestMapper1')
    expect(datapoints[0].run_dir).to eq(File.join(run_dir, '1/'))
    expect(File.exists?(datapoints[0].run_dir)).to be false
    
    osws = scenario.create_osws
    expect(osws.size).to eq(3)
    expect(osws[0]).to eq(File.join(run_dir, '1/in.osw'))
    
    failures = scenario.run
    
    expect(failures).to be_empty
    
    # DLM: TODO, add in post-processing
  end


end
