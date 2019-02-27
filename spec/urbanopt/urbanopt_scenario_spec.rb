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

require_relative '../spec_helper'

RSpec.describe URBANopt::Scenario do
  it 'has a version number' do
    expect(URBANopt::Scenario::VERSION).not_to be nil
  end
  
  it 'can run a scenario' do
    name = 'Example Scenario'
    root_dir = File.join(File.dirname(__FILE__), '../../')
    csv_file = File.join(File.dirname(__FILE__), '../files/example_scenario.csv')
    mapper_files_dir = File.join(File.dirname(__FILE__), '../files/mappers/')
    run_dir = File.join(File.dirname(__FILE__), '../test/example_scenario/')
    
    scenario = URBANopt::Scenario::ScenarioCSV.new(name, root_dir, csv_file, mapper_files_dir, run_dir)
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
  end


end
