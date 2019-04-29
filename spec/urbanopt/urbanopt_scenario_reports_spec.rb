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

RSpec.describe URBANopt::Scenario::Reports do
  
  it 'can construct a scenario report' do
    id = 'feature_1'
    name = 'Feature 1'
    directory_name = 'feature_1' 
    feature_type = 'Building'
    timesteps_per_hour = 4
    simulation_status = 'Complete'
    feature_report_1 = URBANopt::Scenario::Reports::FeatureReport.new(id, name, directory_name, feature_type, timesteps_per_hour, simulation_status)

    id = 'feature_2'
    name = 'Feature 2'
    directory_name = 'feature_2' 
    feature_type = 'Building'
    timesteps_per_hour = 4
    simulation_status = 'Complete'
    feature_report_2 = URBANopt::Scenario::Reports::FeatureReport.new(id, name, directory_name, feature_type, timesteps_per_hour, simulation_status)

    id = 'scenario_1'
    name = 'Scenario 1'
    directory_name = 'scenario_1' 
    timesteps_per_hour = 4
    simulation_status = 'Complete'
    scenario_report = URBANopt::Scenario::Reports::ScenarioReport.new(id, name, directory_name, timesteps_per_hour)
    expect(scenario_report.features.size).to eq(0)
    expect(scenario_report.number_of_not_started_simulations).to eq(0)
    expect(scenario_report.number_of_started_simulations).to eq(0)
    expect(scenario_report.number_of_complete_simulations).to eq(0)
    expect(scenario_report.number_of_failed_simulations).to eq(0)
    
    scenario_report.add_feature(feature_report_1)
    expect(scenario_report.features.size).to eq(1)
    expect(scenario_report.number_of_not_started_simulations).to eq(0)
    expect(scenario_report.number_of_started_simulations).to eq(0)
    expect(scenario_report.number_of_complete_simulations).to eq(1)
    expect(scenario_report.number_of_failed_simulations).to eq(0)
    
    scenario_report.add_feature(feature_report_2)
    expect(scenario_report.features.size).to eq(2)
    expect(scenario_report.number_of_not_started_simulations).to eq(0)
    expect(scenario_report.number_of_started_simulations).to eq(0)
    expect(scenario_report.number_of_complete_simulations).to eq(2)
    expect(scenario_report.number_of_failed_simulations).to eq(0)
    
    
  end

end
