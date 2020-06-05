# *********************************************************************************
# URBANopt, Copyright (c) 2019-2020, Alliance for Sustainable Energy, LLC, and other
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
# *********************************************************************************

require_relative '../spec_helper'
RSpec.describe URBANopt::Scenario::DefaultReports do
  it 'has a logger' do
    expect(URBANopt::Scenario::DefaultReports.logger).not_to be nil
    current_level = URBANopt::Scenario::DefaultReports.logger.level
    URBANopt::Scenario::DefaultReports.logger.level = Logger::DEBUG
    expect(URBANopt::Scenario::DefaultReports.logger.level).to eq Logger::DEBUG
    URBANopt::Scenario::DefaultReports.logger.level = current_level
  end

  it 'can construct a scenario report' do
    feature_report_1 = URBANopt::Scenario::DefaultReports::FeatureReport.new
    feature_report_1.id = 'feature_1'
    feature_report_1.name = 'Feature 1'
    feature_report_1.directory_name = 'feature_1'
    feature_report_1.feature_type = 'Building'
    feature_report_1.timesteps_per_hour = 4
    feature_report_1.simulation_status = 'Complete'
    feature_report_1.program.site_area = 10000
    feature_report_1.program.floor_area = 1000
    feature_report_1.program.conditioned_area = 1000
    feature_report_1.program.unconditioned_area = 0
    feature_report_1.program.footprint_area = 1100

    # feature_report_1.reporting_periods[0][:total_site_energy] = 100

    feature_report_2 = URBANopt::Scenario::DefaultReports::FeatureReport.new
    feature_report_2.id = 'feature_2'
    feature_report_2.name = 'Feature 2'
    feature_report_2.directory_name = 'feature_2'
    feature_report_2.feature_type = 'Building'
    feature_report_2.timesteps_per_hour = 4
    feature_report_2.simulation_status = 'Complete'
    feature_report_2.program.site_area = 10000
    feature_report_2.program.floor_area = 1000
    feature_report_2.program.conditioned_area = 1000
    feature_report_2.program.unconditioned_area = 0
    feature_report_2.program.footprint_area = 1100

    # feature_report_1.reporting_periods[0][:total_site_energy] = 100

    scenario_report = URBANopt::Scenario::DefaultReports::ScenarioReport.new

    expect(scenario_report.feature_reports.size).to eq(0)
    expect(scenario_report.timesteps_per_hour).to be_nil
    expect(scenario_report.number_of_not_started_simulations).to eq(0)
    expect(scenario_report.number_of_started_simulations).to eq(0)
    expect(scenario_report.number_of_complete_simulations).to eq(0)
    expect(scenario_report.number_of_failed_simulations).to eq(0)

    scenario_report.add_feature_report(feature_report_1)
    expect(scenario_report.feature_reports.size).to eq(1)
    expect(scenario_report.timesteps_per_hour).to eq(4)
    expect(scenario_report.number_of_not_started_simulations).to eq(0)
    expect(scenario_report.number_of_started_simulations).to eq(0)
    expect(scenario_report.number_of_complete_simulations).to eq(1)
    expect(scenario_report.number_of_failed_simulations).to eq(0)

    scenario_report.add_feature_report(feature_report_2)
    expect(scenario_report.feature_reports.size).to eq(2)
    expect(scenario_report.timesteps_per_hour).to eq(4)
    expect(scenario_report.number_of_not_started_simulations).to eq(0)
    expect(scenario_report.number_of_started_simulations).to eq(0)
    expect(scenario_report.number_of_complete_simulations).to eq(2)
    expect(scenario_report.number_of_failed_simulations).to eq(0)

    expect(scenario_report.program.site_area).to eq(20000)
    expect(scenario_report.program.floor_area).to eq(2000)
    expect(scenario_report.program.conditioned_area).to eq(2000)
    expect(scenario_report.program.unconditioned_area).to eq(0)
    expect(scenario_report.program.footprint_area).to eq(2200)
  end

  it 'can merge construction costs together' do
    existing_costs = []
    new_costs = []

    new_costs << URBANopt::Scenario::DefaultReports::ConstructionCost.new(category: 'Construction', item_name: 'wall', unit_cost: 1,
                                                                          cost_units: 'CostPerEach', item_quantity: 1, total_cost: 1)
    new_costs << URBANopt::Scenario::DefaultReports::ConstructionCost.new(category: 'Construction', item_name: 'roof', unit_cost: 1,
                                                                          cost_units: 'CostPerEach', item_quantity: 1, total_cost: 1)

    existing_costs << URBANopt::Scenario::DefaultReports::ConstructionCost.new(category: 'Construction', item_name: 'wall', unit_cost: 1,
                                                                               cost_units: 'CostPerEach', item_quantity: 1, total_cost: 1)
    existing_costs << URBANopt::Scenario::DefaultReports::ConstructionCost.new(category: 'HVACComponent', item_name: 'hvac', unit_cost: 1,
                                                                               cost_units: 'CostPerEach', item_quantity: 1, total_cost: 1)

    # puts "existing_costs = #{existing_costs}"
    # puts "new_costs = #{new_costs}"

    construction_cost = URBANopt::Scenario::DefaultReports::ConstructionCost.merge_construction_costs(existing_costs, new_costs)

    if construction_cost[0].item_name == 'wall'
      expect(construction_cost[0].category).to eq('Construction')
      expect(construction_cost[0].unit_cost).to eq(1)
      expect(construction_cost[0].cost_units).to eq('CostPerEach')
      expect(construction_cost[0].item_quantity).to eq(2)
      expect(construction_cost[0].total_cost).to eq(2)
    end

    if construction_cost[1].item_name == 'hvac'
      expect(construction_cost[1].category).to eq('HVACComponent')
      expect(construction_cost[1].unit_cost).to eq(1)
      expect(construction_cost[1].cost_units).to eq('CostPerEach')
      expect(construction_cost[1].item_quantity).to eq(1)
      expect(construction_cost[1].total_cost).to eq(1)
    end

    if construction_cost[2].item_name == 'roof'
      expect(construction_cost[2].category).to eq('Construction')
      expect(construction_cost[2].unit_cost).to eq(1)
      expect(construction_cost[2].cost_units).to eq('CostPerEach')
      expect(construction_cost[2].item_quantity).to eq(1)
      expect(construction_cost[2].total_cost).to eq(1)
    end

    # puts "final cost = #{existing_costs}"
  end

  it 'can merge end uses' do
    existing_end_uses = URBANopt::Scenario::DefaultReports::EndUses.new(electricity: { heating: 1, cooling: 1 }, natural_gas: { fans: 1, pumps: 1 })
    new_end_uses = URBANopt::Scenario::DefaultReports::EndUses.new(electricity: { heating: 1, cooling: 1 }, natural_gas: { fans: 1, pumps: 1 })

    existing_end_uses.merge_end_uses!(new_end_uses)

    expect(existing_end_uses.electricity.heating).to eq(2)
    expect(existing_end_uses.electricity.cooling).to eq(2)
    expect(existing_end_uses.natural_gas.fans).to eq(2)
    expect(existing_end_uses.natural_gas.pumps).to eq(2)
  end

  it 'can merge reporting periods together' do
    existing_periods = []
    new_periods = []

    existing_periods << URBANopt::Scenario::DefaultReports::ReportingPeriod.new(
      id: 5, name: 'Annual', multiplier: 1, start_date: { month: 1, day_of_month: 1, year: 2019 },
      end_date: { month: 12, day_of_month: 31, year: 2019 }, total_site_energy: 1, total_source_energy: 1,
      end_uses: { electricity: { heating: 1, cooling: 1, fans: 1, pumps: 1 } }, utility_costs: [{ fuel_type: 'Electricity', total_cost: 1, usage_cost: 1, demand_cost: 1 }]
    )
    existing_periods << URBANopt::Scenario::DefaultReports::ReportingPeriod.new(
      id: 6, name: 'January', multiplier: 1, start_date: { month: 1, day_of_month: 1, year: 2019 },
      end_date: { month: 1, day_of_month: 31, year: 2019 }, total_site_energy: 1, total_source_energy: 1,
      end_uses: { electricity: { heating: 1, cooling: 1, fans: 1, pumps: 1 } }, utility_costs: [{ fuel_type: 'Electricity', total_cost: 1, usage_cost: 1, demand_cost: 1 }]
    )

    new_periods << URBANopt::Scenario::DefaultReports::ReportingPeriod.new(
      id: 5, name: 'Annual', multiplier: 1, start_date: { month: 1, day_of_month: 1, year: 2019 },
      end_date: { month: 12, day_of_month: 31, year: 2019 }, total_site_energy: 1, total_source_energy: 1,
      end_uses: { electricity: { heating: 1, cooling: 1, fans: 1, pumps: 1 } }, utility_costs: [{ fuel_type: 'Electricity', total_cost: 1, usage_cost: 1, demand_cost: 1 }]
    )
    new_periods << URBANopt::Scenario::DefaultReports::ReportingPeriod.new(id: 6, name: 'January', multiplier: 1, start_date: { month: 1, day_of_month: 1, year: 2019 },
                                                                           end_date: { month: 1, day_of_month: 31, year: 2019 }, total_site_energy: 1, total_source_energy: 1,
                                                                           end_uses: { electricity: { heating: 1, cooling: 1, fans: 1, pumps: 1 } }, utility_costs: [{ fuel_type: 'Electricity', total_cost: 1, usage_cost: 1, demand_cost: 1 }])

    # puts "\nexisting periods: #{existing_periods}"
    # puts "\nnew periods: #{new_periods}"

    reporting_period = URBANopt::Scenario::DefaultReports::ReportingPeriod.merge_reporting_periods(existing_periods, new_periods)

    expect(reporting_period[0].id).to eq(5)
    expect(reporting_period[0].name).to eq('Annual')
    expect(reporting_period[0].multiplier).to eq(1)
    expect(reporting_period[0].start_date.month).to eq(1)
    expect(reporting_period[0].start_date.day_of_month).to eq(1)
    expect(reporting_period[0].start_date.year).to eq(2019)
    expect(reporting_period[0].end_date.month).to eq(12)
    expect(reporting_period[0].end_date.day_of_month).to eq(31)
    expect(reporting_period[0].end_date.year).to eq(2019)
    expect(reporting_period[0].total_site_energy).to eq(2)
    expect(reporting_period[0].total_source_energy).to eq(2)
    expect(reporting_period[0].end_uses.electricity.heating).to eq(2)
    expect(reporting_period[0].end_uses.electricity.cooling).to eq(2)
    expect(reporting_period[0].end_uses.electricity.fans).to eq(2)
    expect(reporting_period[0].end_uses.electricity.pumps).to eq(2)

    expect(reporting_period[1].id).to eq(6)
    expect(reporting_period[1].name).to eq('January')
    expect(reporting_period[1].multiplier).to eq(1)
    expect(reporting_period[1].start_date.month).to eq(1)
    expect(reporting_period[1].start_date.day_of_month).to eq(1)
    expect(reporting_period[1].start_date.year).to eq(2019)
    expect(reporting_period[1].end_date.month).to eq(1)
    expect(reporting_period[1].end_date.day_of_month).to eq(31)
    expect(reporting_period[1].end_date.year).to eq(2019)
    expect(reporting_period[1].total_site_energy).to eq(2)
    expect(reporting_period[1].total_source_energy).to eq(2)
    expect(reporting_period[1].end_uses.electricity.heating).to eq(2)
    expect(reporting_period[1].end_uses.electricity.cooling).to eq(2)
    expect(reporting_period[1].end_uses.electricity.fans).to eq(2)
    expect(reporting_period[1].end_uses.electricity.pumps).to eq(2)

    # puts "\nfinal periods: #{existing_periods}"
  end
end
# rubocop: enable Metrics/BlockLength
