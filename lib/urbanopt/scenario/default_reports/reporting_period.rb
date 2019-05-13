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

require 'json'

module URBANopt
  module Scenario
    module DefaultReports
      class ReportingPeriod 

        attr_accessor :id, :name, :multiplier, :start_date, :end_date, :month, :day_of_month, :year, :total_site_energy, :total_source_energy, :net_site_energy, :net_source_energy, :net_utility_cost, :electricity, :natural_gas, :additional_fuel, :district_cooling, :district_heating, :water, :electricity_produced, :end_uses, :heating, :cooling, :interior_lighting, :exterior_lighting, :interior_equipment, :exterior_equipment, :fans, :pumps, :heat_rejection, :humidification, :heat_recovery, :water_systems, :refrigeration, :generators,  :energy_production, :electricity_produced, :photovoltaic, :utility_costs, :fuel_type, :total_cost, :usage_cost, :demand_cost, :comfort_result, :time_setpoint_not_met_during_occupied_cooling, :time_setpoint_not_met_during_occupied_heating, :time_setpoint_not_met_during_occupied_hours

        # perform initialization functions
        def initialize(hash = {})
          hash.delete_if {|k, v| v.nil?}
          hash = defaults.merge(hash)
          
          @id = hash[:id]
          @name = hash[:name]
          @multiplier = hash[:multiplier]
          @start_date = hash[:start_date]
          @end_date = hash[:end_date]
          @month = hash[:month]
          @day_of_month = hash[:day_of_month]
          @year = hash[:year]
          @total_site_energy = hash[:total_site_energy]
          @total_source_energy = hash[:total_source_energy]
          @net_site_energy = hash [:net_site_energy]
          @net_source_energy = hash [:net_source_energy]
          @net_utility_cost = hash [:net_utility_cost]
          @electricity = hash [:electricity]
          @natural_gas = hash [:natural_gas]
          @additional_fuel = hash [:additional_fuel]
          @district_cooling = hash [:district_cooling]
          @district_heating = hash[:district_heating]
          @water = hash[:water]
          @electricity_produced = hash[:electricity_produced]
          @end_uses = hash[:end_uses]
          @heating = hash[:heating]
          @cooling = hash[:cooling]
          @interior_lighting = hash[:interior_lighting]
          @exterior_lighting = hash[:exterior_lighting]
          @interior_equipment = hash[:interior_equipment]
          @exterior_equipment = hash[:exterior_equipment]
          @fans = hash[:fans]
          @pumps = hash[:pumps]
          @heat_rejection = hash[:heat_rejection]
          @humidification = hash[:humidification]
          @heat_recovery = hash[:heat_recovery]
          @water_systems = hash[:water_systems]
          @refrigeration = hash[:refrigeration]
          @generators = hash[:generators]
          @energy_production = hash[:energy_production]
          @electricity_produced = hash[:electricity_produced]
          @photovoltaic = hash[:photovoltaic]
          @utility_costs = hash[:utility_costs]
          @fuel_type = hash[:fuel_type]
          @total_cost = hash[:total_cost]
          @usage_cost = hash[:usage_cost]
          @demand_cost = hash[:demand_cost]
          @comfort_result = hash[:comfort_result]
          @time_setpoint_not_met_during_occupied_cooling = hash[:time_setpoint_not_met_during_occupied_cooling]
          @time_setpoint_not_met_during_occupied_heating = hash[:time_setpoint_not_met_during_occupied_heating]
          @time_setpoint_not_met_during_occupied_hours = hash[:time_setpoint_not_met_during_occupied_hours]

        end
                
        def defaults
          hash = {}

          hash[:id] = 0
          hash[:name] = 0

          return hash
        end
        
        def to_hash
          result = {}

          result[:id] =  @id if @id
          result[:name] = @name if @name
          result[:multiplier] = @multiplier if @multiplier
          result[:start_date] = @start_date if @start_date
          result[:end_date] = @end_date if @end_date 
          result[:month] = @month if @month
          result[:day_of_month] = @day_of_month if @day_of_month
          result[:year] = @year if @year
          result[:total_site_energy] = @total_site_energy if @total_site_energy 
          result[:total_source_energy] = @total_source_energy if @total_source_energy
          result[:net_site_energy] = @net_site_energy if @net_site_energy
          result[:net_source_energy] = @net_source_energy if @net_source_energy
          result[:net_utility_cost] = @net_utility_cost if @net_utility_cost
          result[:electricity] = @electricity if @electricity
          result[:natural_gas] = @natural_gas if @natural_gas 
          result[:additional_fuel] = @additional_fuel if @additional_fuel 
          result[:district_cooling] = @district_cooling if @district_cooling 
          result[:district_heating] = @district_heating if @district_heating 
          result[:water] = @water if @water 
          result[:electricity_produced] = @electricity_produced if @electricity_produced
          result[:end_uses] = @end_uses if @end_uses 
          result[:heating] = @heating if @heating 
          result[:cooling] = @cooling if @cooling 
          result[:interior_lighting] = @interior_lighting if @interior_lighting
          result[:exterior_lighting] = @exterior_lighting if @exterior_lighting 
          result[:interior_equipment] = @interior_equipment if @interior_equipment
          result[:exterior_equipment] = @exterior_equipment if @exterior_equipment 
          result[:fans] = @fans if @fans 
          result[:pumps] = @pumps if @pumps
          result[:heat_rejection] = @heat_rejection if @heat_rejection
          result[:humidification] = @humidification if @humidification 
          result[:heat_recovery] = @heat_recovery if @heat_recovery
          result[:water_systems] = @water_systems if @water_systems 
          result[:refrigeration] = @refrigeration if @refrigeration 
          result[:generators] = @generators if @generators 
          result[:energy_production] = @energy_production if @energy_production 
          result[:electricity_produced] = @electricity_produced if @electricity_produced
          result[:photovoltaic] = @photovoltaic if @photovoltaic 
          result[:utility_costs] = @utility_costs if @utility_costs 
          result[:fuel_type] = @fuel_type if @fuel_type 
          result[:total_cost] = @total_cost if @total_cost 
          result[:usage_cost] = @usage_cost if @usage_cost 
          result[:demand_cost] = @demand_cost if @demand_cost
          result[:comfort_result] = @comfort_result if @comfort_result 
          result[:time_setpoint_not_met_during_occupied_cooling] = @time_setpoint_not_met_during_occupied_cooling if @time_setpoint_not_met_during_occupied_cooling 
          result[:time_setpoint_not_met_during_occupied_heating] = @time_setpoint_not_met_during_occupied_heating if @time_setpoint_not_met_during_occupied_heating 
          result[:time_setpoint_not_met_during_occupied_hours] = @time_setpoint_not_met_during_occupied_hours if @time_setpoint_not_met_during_occupied_hours

          return result
        end
        
        def self.merge_reporting_period(existing_period, new_period)
                            
          # modify the existing_period by summing up the results
          existing_period.total_site_energy += new_period.total_site_energy
          existing_period.total_source_energy += new_period.total_source_energy
          existing_period.net_site_energy += new_period.net_site_energy
          existing_period.net_source_energy += new_period.net_source_energy
          existing_period.net_utility_cost += new_period.net_utility_cost
          existing_period.electricity += new_period.electricity
          existing_period.natural_gas += new_period.natural_gas
          existing_period.additional_fuel += new_period.additional_fuel
          existing_period.district_cooling += new_period.district_cooling
          existing_period.district_heating += new_period.district_heating
          existing_period.water += new_period.water
          existing_period.electricity_produced += new_period.electricity_produced
          existing_period.heating += new_period.heating
          existing_period.cooling += new_period.cooling
          existing_period.interior_lighting += new_period.interior_lighting
          existing_period.exterior_lighting += new_period.exterior_lighting
          existing_period.interior_equipment += new_period.interior_equipment
          existing_period.exterior_equipment += new_period.exterior_equipment
          existing_period.fans += new_period.fans
          existing_period.pumps += new_period.pumps
          existing_period.heat_rejection += new_period.heat_rejection
          existing_period.humidification += new_period.humidification
          existing_period.heat_recovery += new_period.heat_recovery
          existing_period.water_systems += new_period.water_systems
          existing_period.refrigeration += new_period.refrigeration
          existing_period.generators += new_period.generators
          existing_period.photovoltaic += new_period.photovoltaic
          existing_period.usage_cost += new_period.usage_cost
          existing_period.demand_cost += new_period.demand_cost
          existing_period.time_setpoint_not_met_during_occupied_cooling += new_period.time_setpoint_not_met_during_occupied_cooling
          existing_period.time_setpoint_not_met_during_occupied_heating += new_period.time_setpoint_not_met_during_occupied_heating
          existing_period.time_setpoint_not_met_during_occupied_heating += new_period.time_setpoint_not_met_during_occupied_heating
          existing_period.time_setpoint_not_met_during_occupied_hours += new_period.time_setpoint_not_met_during_occupied_hours         
                             
          return existing_period
        end
        
        def self.merge_reporting_periods(existing_periods, new_periods)
                    
          # TODO: match new periods to existing periods and call merge_reporting_period
          #puts "existing_periods = #{existing_periods.name}"
          #puts "new_periods = #{new_periods.name}"

          id_list = []
          id_list = existing_periods.collect {|x| x.id}
      
          new_periods.each do |x_new|
              
            if id_list.include?(x_new.id)
                  
              # when looping over the new_periods ids find the index of the id_list with the same id            
              index = id_list.find_index(x_new.id)
                    
              # modify the existing_periods by merging the new periods
              existing_periods[index] = merge_reporting_period(existing_periods[index], x_new)
      
            else
              #insert the new hash in to the array 
              existing_periods << x_new

            end

            puts "final periods = #{existing_periods}"
             
            return existing_periods
        
          end
        end
      end
    end
  end
end