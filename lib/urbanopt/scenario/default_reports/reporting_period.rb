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
require 'urbanopt/scenario/default_reports/end_uses'
require 'urbanopt/scenario/default_reports/end_use'

module URBANopt
  module Scenario
    module DefaultReports
      class ReportingPeriod 

        attr_accessor :id, :name, :multiplier, :start_date, :end_date, :month, :day_of_month, :year, :total_site_energy, :total_source_energy, :net_site_energy, :net_source_energy, :net_utility_cost, :electricity, :natural_gas, :additional_fuel, :district_cooling, :district_heating, :water, :electricity_produced, :end_uses, :energy_production, :electricity_produced, :photovoltaic, :utility_costs, :fuel_type, :total_cost, :usage_cost, :demand_cost, :comfort_result, :time_setpoint_not_met_during_occupied_cooling, :time_setpoint_not_met_during_occupied_heating, :time_setpoint_not_met_during_occupied_hours

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
          @end_uses = EndUses.new(hash[:end_uses])
          
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
          hash[:name] = 'period name'
          hash[:multiplier] = 1
          hash[:start_date] = {month: 0 ,day_of_month: 0 , year: 0}
          hash[:end_date] = {month: 0 , day_of_month: 0 , year: 0}
          hash[:energy_production] = {electricity_produced: {photovoltaic: 0, }}
          hash[:utility_costs] = { fuel_type:'', total_cost: 0, usage_cost: 0, demand_cost: 0}
          hash[:comfort_result] = {time_setpoint_not_met_during_occupied_cooling: 0, time_setpoint_not_met_during_occupied_heating: 0, time_setpoint_not_met_during_occupied_hours: 0}
          hash[:end_uses] = EndUses.new.to_hash
          
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


        # def self.get_all_keys(h)
        #   h.each_with_object([]){|(k,v),a| v.is_a?(Hash) ? a.push(k,*get_all_keys(v)) : a << k }
        # end

        
        def self.merge_reporting_period(existing_period, new_period)
                            
          # modify the existing_period by summing up the results ; # sum results only if they exist
          
          #try to create a class for enduse 

          existing_period.total_site_energy += new_period.total_site_energy if existing_period.total_site_energy
          existing_period.total_source_energy += new_period.total_source_energy if existing_period.total_source_energy  
          existing_period.net_source_energy += new_period.net_source_energy if existing_period.net_source_energy 
          existing_period.net_utility_cost += new_period.net_utility_cost if existing_period.net_utility_cost
          existing_period.electricity += new_period.electricity if existing_period.electricity
          existing_period.natural_gas += new_period.natural_gas if existing_period.natural_gas
          existing_period.additional_fuel += new_period.additional_fuel if existing_period.additional_fuel
          existing_period.district_cooling += new_period.district_cooling if existing_period.district_cooling
          existing_period.district_heating += new_period.district_heating if existing_period.district_heating
          existing_period.water += new_period.water if existing_period.water
          existing_period.electricity_produced += new_period.electricity_produced if existing_period.electricity_produced
        
          
            #merge end uses
            new_end_uses = new_period.end_uses
            existing_period.end_uses.merge_end_uses!(new_end_uses) if existing_period.end_uses
          

          if existing_period.energy_production
            if existing_period.energy_production[:electricity_produced]
              existing_period.energy_production[:electricity_produced][:electricity_produced] += new_period.energy_production[:electricity_produced][:electricity_produced] if existing_period.energy_production[:electricity_produced][:electricity_produced]
            end
          end

          if existing_period.utility_costs
            existing_period.utility_costs[:fuel_type] += new_period.utility_costs[:fuel_type] if existing_period.utility_costs[:fuel_type]
            existing_period.utility_costs[:total_cost] += new_period.utility_costs[:total_cost] if existing_period.utility_costs[:total_cost]
            existing_period.utility_costs[:usage_cost] += new_period.utility_costs[:usage_cost] if existing_period.utility_costs[:usage_cost]
            existing_period.utility_costs[:demand_cost] += new_period.utility_costs[:demand_cost] if existing_period.utility_costs[:demand_cost]
          end
          
          if existing_period.comfort_result
            existing_period.comfort_result[:time_setpoint_not_met_during_occupied_cooling] += new_period.comfort_result[:time_setpoint_not_met_during_occupied_cooling] if existing_period.comfort_result[:time_setpoint_not_met_during_occupied_cooling]
            existing_period.comfort_result[:time_setpoint_not_met_during_occupied_heating] += new_period.comfort_result[:time_setpoint_not_met_during_occupied_heating] if existing_period.comfort_result[:time_setpoint_not_met_during_occupied_heating]
            existing_period.comfort_result[:time_setpoint_not_met_during_occupied_hours] += new_period.comfort_result[:time_setpoint_not_met_during_occupied_hours] if existing_period.comfort_result[:time_setpoint_not_met_during_occupied_hours]
          end         
                         
          return existing_period
         
        end
        
        def self.merge_reporting_periods(existing_periods, new_periods)
                    
          # TODO: match new periods to existing periods and call merge_reporting_period

          id_list_existing = []
          id_list_new = []
          id_list_existing = existing_periods.collect {|x| x.id}
          id_list_new = new_periods.collect {|x| x.id}

          puts "\nexisting periods ids: #{id_list_new}"
          puts "new periods ids: #{id_list_new}"
                 
          if id_list_existing == id_list_new 
                
            existing_periods.each_index do |index|
              # existing_keys = get_all_keys(existing_periods[index])
              # new_keys = get_all_keys(new_periods[index])
              # if new_keys == existing_keys
                # modify the existing_periods by merging the new periods results
            existing_periods[index] = merge_reporting_period(existing_periods[index], new_periods[index])
              # else 
              #   #raise and error if the elements (all keys) in the reporting periods are not identical
              #   raise "reperting periods with unidentical elements cannot be merged"
              # end
            end
            
          elsif existing_periods.empty?
            # if existing periods are empty, take the new periods
            existing_periods = new_periods
                       
          else
            # raise an error if the existing periods are not identical with new periods (cannot have different reporting period ids)
            raise "cannot merge different reporting periods"

          end
          
          return existing_periods

        end
      end
    end
  end
end

