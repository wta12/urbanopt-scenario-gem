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
          
          #@electricity_produced = hash[:electricity_produced]
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
          hash[:end_uses] = {electricity: {heating: 0, cooling: 0, }, natural_gas: {heating: 0, cooling:0,}, additional_fuel:{ }, district_cooling:{ }, district_heating:{ }, water:{ } }
          
          hash[:electricity] =  {heating: 0, cooling: 0, }
          hash[:energy_production] = {electricity_produced: {photovoltaic: 0, }}
          hash[:utility_costs] = { fuel_type:'', total_cost: 0, usage_cost: 0, demand_cost: 0}
          hash[:comfort_result] = {time_setpoint_not_met_during_occupied_cooling: 0, time_setpoint_not_met_during_occupied_heating: 0, time_setpoint_not_met_during_occupied_hours: 0}
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
          # result[:electricity] = @electricity if @electricity
          # result[:natural_gas] = @natural_gas if @natural_gas 
          # result[:additional_fuel] = @additional_fuel if @additional_fuel 
          # result[:district_cooling] = @district_cooling if @district_cooling 
          # result[:district_heating] = @district_heating if @district_heating 
          # result[:water] = @water if @water 
          

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


        def self.get_all_keys(h)
          h.each_with_object([]){|(k,v),a| v.is_a?(Hash) ? a.push(k,*get_all_keys(v)) : a << k }
        end

        
        def self.merge_reporting_period(existing_period, new_period)
                            
          # modify the existing_period by summing up the results ; # sum results only if they exist
          
          #try to create a class for enduse 

         
          existing_period[:total_site_energy] += new_period[:total_site_energy] if existing_period.include?(:total_site_energy)
          existing_period[:total_source_energy] += new_period[:total_source_energy] if existing_period.include?(:total_source_energy)  
          existing_period[:net_source_energy] += new_period[:net_source_energy] if existing_period.include?(:net_source_energy) 
          existing_period[:net_utility_cost] += new_period[:net_utility_cost] if existing_period.include?(:net_utility_cost)
          existing_period[:electricity] += new_period[:electricity] if existing_period.include?(:electricity)
          existing_period[:natural_gas] += new_period[:natural_gas] if existing_period.include?(:natural_gas)
          existing_period[:additional_fuel] += new_period[:additional_fuel] if existing_period.include?(:additional_fuel)
          existing_period[:district_cooling] += new_period[:district_cooling] if existing_period.include?(:district_cooling)
          existing_period[:district_heating] += new_period[:district_heating] if existing_period.include?(:district_heating)
          existing_period[:water] += new_period[:water] if existing_period.include?(:water)
          existing_period[:electricity_produced] += new_period[:electricity_produced] if existing_period.include?(:electricity_produced)
        


          if existing_period.include?(:end_uses)

            if existing_period[:end_uses].include?(:electricity)
              existing_period[:end_uses][:electricity][:heating] += new_period[:end_uses][:electricity][:heating] if existing_period[:end_uses][:electricity].include?(:heating)
              existing_period[:end_uses][:electricity][:cooling] += new_period[:end_uses][:electricity][:cooling] if existing_period[:end_uses][:electricity].include?(:cooling)
              existing_period[:end_uses][:electricity][:interior_lighting] += new_period[:end_uses][:electricity][:interior_lighting] if existing_period[:end_uses][:electricity].include?(:interior_lighting)
              existing_period[:end_uses][:electricity][:exterior_lighting] += new_period[:end_uses][:electricity][:exterior_lighting] if existing_period[:end_uses][:electricity].include?(:exterior_lighting)
              existing_period[:end_uses][:electricity][:interior_equipment] += new_period[:end_uses][:electricity][:interior_equipment] if existing_period[:end_uses][:electricity].include?(:interior_equipment)
              existing_period[:end_uses][:electricity][:exterior_equipment] += new_period[:end_uses][:electricity][:exterior_equipment] if existing_period[:end_uses][:electricity].include?(:exterior_equipment)
              existing_period[:end_uses][:electricity][:fans] += new_period[:end_uses][:electricity][:fans] if existing_period[:end_uses][:electricity].include?(:fans)
              existing_period[:end_uses][:electricity][:pumps] += new_period[:end_uses][:electricity][:pumps] if existing_period[:end_uses][:electricity].include?(:pumps)
              existing_period[:end_uses][:electricity][:heat_rejection] += new_period[:end_uses][:electricity][:heat_rejection] if existing_period[:end_uses][:electricity].include?(:heat_rejection)
              existing_period[:end_uses][:electricity][:humidification] += new_period[:end_uses][:electricity][:humidification] if existing_period[:end_uses][:electricity].include?(:humidification)
              existing_period[:end_uses][:electricity][:heat_recovery] += new_period[:end_uses][:electricity][:heat_recovery] if existing_period[:end_uses][:electricity].include?(:heat_recovery)
              existing_period[:end_uses][:electricity][:water_systems] += new_period[:end_uses][:electricity][:water_systems] if existing_period[:end_uses][:electricity].include?(:water_systems)
              existing_period[:end_uses][:electricity][:refrigeration] += new_period[:end_uses][:electricity][:refrigeration] if existing_period[:end_uses][:electricity].include?(:refrigeration)
              existing_period[:end_uses][:electricity][:generators] += new_period[:end_uses][:electricity][:generators] if existing_period[:end_uses][:electricity].include?(:generators)
            end  

            if existing_period[:end_uses].include?(:natural_gas)
              existing_period[:end_uses][:natural_gas][:heating] += new_period[:end_uses][:natural_gas][:heating] if existing_period[:end_uses][:natural_gas].include?(:heating)
              existing_period[:end_uses][:natural_gas][:cooling] += new_period[:end_uses][:natural_gas][:cooling] if existing_period[:end_uses][:natural_gas].include?(:cooling)
              existing_period[:end_uses][:natural_gas][:interior_lighting] += new_period[:end_uses][:natural_gas][:interior_lighting] if existing_period[:end_uses][:natural_gas].include?(:interior_lighting)
              existing_period[:end_uses][:natural_gas][:exterior_lighting] += new_period[:end_uses][:natural_gas][:exterior_lighting] if existing_period[:end_uses][:natural_gas].include?(:exterior_lighting)
              existing_period[:end_uses][:natural_gas][:interior_equipment] += new_period[:end_uses][:natural_gas][:interior_equipment] if existing_period[:end_uses][:natural_gas].include?(:interior_equipment)
              existing_period[:end_uses][:natural_gas][:exterior_equipment] += new_period[:end_uses][:natural_gas][:exterior_equipment] if existing_period[:end_uses][:natural_gas].include?(:exterior_equipment)
              existing_period[:end_uses][:natural_gas][:fans] += new_period[:end_uses][:natural_gas][:fans] if  existing_period[:end_uses][:natural_gas].include?(:fans)
              existing_period[:end_uses][:natural_gas][:pumps] += new_period[:end_uses][:natural_gas][:pumps] if existing_period[:end_uses][:natural_gas].include?(:pumps)
              existing_period[:end_uses][:natural_gas][:heat_rejection] += new_period[:end_uses][:natural_gas][:heat_rejection] if existing_period[:end_uses][:natural_gas].include?(:heat_rejection)
              existing_period[:end_uses][:natural_gas][:humidification] += new_period[:end_uses][:natural_gas][:humidification] if existing_period[:end_uses][:natural_gas].include?(:humidification)
              existing_period[:end_uses][:natural_gas][:heat_recovery] += new_period[:end_uses][:natural_gas][:heat_recovery] if existing_period[:end_uses][:natural_gas].include?(:heat_recovery)
              existing_period[:end_uses][:natural_gas][:water_systems] += new_period[:end_uses][:natural_gas][:water_systems] if existing_period[:end_uses][:natural_gas].include?(:water_systems)
              existing_period[:end_uses][:natural_gas][:refrigeration] += new_period[:end_uses][:natural_gas][:refrigeration] if  existing_period[:end_uses][:natural_gas].include?(:refrigeration)
              existing_period[:end_uses][:natural_gas][:generators] += new_period[:end_uses][:natural_gas][:generators] if existing_period[:end_uses][:natural_gas].include?(:generators) 
            end

            if existing_period[:end_uses].include?(:additional_fuel)
              existing_period[:end_uses][:additional_fuel][:heating] += new_period[:end_uses][:additional_fuel][:heating] if existing_period[:end_uses][:additional_fuel].include?(:heating)
              existing_period[:end_uses][:additional_fuel][:cooling] += new_period[:end_uses][:additional_fuel][:cooling] if existing_period[:end_uses][:additional_fuel].include?(:cooling)
              existing_period[:end_uses][:additional_fuel][:interior_lighting] += new_period[:end_uses][:additional_fuel][:interior_lighting] if existing_period[:end_uses][:additional_fuel].include?(:interior_lighting)
              existing_period[:end_uses][:additional_fuel][:exterior_lighting] += new_period[:end_uses][:additional_fuel][:exterior_lighting] if existing_period[:end_uses][:additional_fuel].include?(:exterior_lighting)
              existing_period[:end_uses][:additional_fuel][:interior_equipment] += new_period[:end_uses][:additional_fuel][:interior_equipment] if existing_period[:end_uses][:additional_fuel].include?(:interior_equipment)
              existing_period[:end_uses][:additional_fuel][:exterior_equipment] += new_period[:end_uses][:additional_fuel][:exterior_equipment] if existing_period[:end_uses][:additional_fuel].include?(:exterior_equipment)
              existing_period[:end_uses][:additional_fuel][:fans] += new_period[:end_uses][:additional_fuel][:fans] if existing_period[:end_uses][:additional_fuel].include?(:fans)
              existing_period[:end_uses][:additional_fuel][:pumps] += new_period[:end_uses][:additional_fuel][:pumps] if existing_period[:end_uses][:additional_fuel].include?(:pumps)
              existing_period[:end_uses][:additional_fuel][:heat_rejection] += new_period[:end_uses][:additional_fuel][:heat_rejection] if existing_period[:end_uses][:additional_fuel].include?(:heat_rejection)
              existing_period[:end_uses][:additional_fuel][:humidification] += new_period[:end_uses][:additional_fuel][:humidification] if existing_period[:end_uses][:additional_fuel].include?(:humidification)
              existing_period[:end_uses][:additional_fuel][:heat_recovery] += new_period[:end_uses][:additional_fuel][:heat_recovery] if existing_period[:end_uses][:additional_fuel].include?(:heat_recovery)
              existing_period[:end_uses][:additional_fuel][:water_systems] += new_period[:end_uses][:additional_fuel][:water_systems] if existing_period[:end_uses][:additional_fuel].include?(:water_systems)
              existing_period[:end_uses][:additional_fuel][:refrigeration] += new_period[:end_uses][:additional_fuel][:refrigeration] if existing_period[:end_uses][:additional_fuel].include?(:refrigeration)
              existing_period[:end_uses][:additional_fuel][:generators] += new_period[:end_uses][:additional_fuel][:generators] if existing_period[:end_uses][:additional_fuel].include?(:generators) 
            end
            
            if existing_period[:end_uses].include?(:district_cooling)
              existing_period[:end_uses][:district_cooling][:heating] += new_period[:end_uses][:district_cooling][:heating] if existing_period[:end_uses][:district_cooling].include?(:heating)
              existing_period[:end_uses][:district_cooling][:cooling] += new_period[:end_uses][:district_cooling][:cooling] if existing_period[:end_uses][:district_cooling].include?(:cooling)
              existing_period[:end_uses][:district_cooling][:interior_lighting] += new_period[:end_uses][:district_cooling][:interior_lighting] if existing_period[:end_uses][:district_cooling].include?(:interior_lighting)
              existing_period[:end_uses][:district_cooling][:exterior_lighting] += new_period[:end_uses][:district_cooling][:exterior_lighting] if existing_period[:end_uses][:district_cooling].include?(:exterior_lighting)
              existing_period[:end_uses][:district_cooling][:interior_equipment] += new_period[:end_uses][:district_cooling][:interior_equipment] if existing_period[:end_uses][:district_cooling].include?(:interior_equipment)
              existing_period[:end_uses][:district_cooling][:exterior_equipment] += new_period[:end_uses][:district_cooling][:exterior_equipment] if existing_period[:end_uses][:district_cooling].include?(:exterior_equipment)
              existing_period[:end_uses][:district_cooling][:fans] += new_period[:end_uses][:district_cooling][:fans] if existing_period[:end_uses][:district_cooling].include?(:fans)
              existing_period[:end_uses][:district_cooling][:pumps] += new_period[:end_uses][:district_cooling][:pumps] if existing_period[:end_uses][:district_cooling].include?(:pumps)
              existing_period[:end_uses][:district_cooling][:heat_rejection] += new_period[:end_uses][:district_cooling][:heat_rejection] if existing_period[:end_uses][:district_cooling].include?(:heat_rejection)
              existing_period[:end_uses][:district_cooling][:humidification] += new_period[:end_uses][:district_cooling][:humidification] if existing_period[:end_uses][:district_cooling].include?(:humidification)
              existing_period[:end_uses][:district_cooling][:heat_recovery] += new_period[:end_uses][:district_cooling][:heat_recovery] if existing_period[:end_uses][:district_cooling].include?(:heat_recovery)
              existing_period[:end_uses][:district_cooling][:water_systems] += new_period[:end_uses][:district_cooling][:water_systems] if existing_period[:end_uses][:district_cooling].include?(:water_systems)
              existing_period[:end_uses][:district_cooling][:refrigeration] += new_period[:end_uses][:district_cooling][:refrigeration] if existing_period[:end_uses][:district_cooling].include?(:refrigeration)
              existing_period[:end_uses][:district_cooling][:generators] += new_period[:end_uses][:district_cooling][:generators] if existing_period[:end_uses][:district_cooling].include?(:generators) 
            end

            if existing_period[:end_uses].include?(:district_heating)
              existing_period[:end_uses][:district_heating][:heating] += new_period[:end_uses][:district_heating][:heating] if existing_period[:end_uses][:district_heating].include?(:heating)
              existing_period[:end_uses][:district_heating][:cooling] += new_period[:end_uses][:district_heating][:cooling] if existing_period[:end_uses][:district_heating].include?(:cooling)
              existing_period[:end_uses][:district_heating][:interior_lighting] += new_period[:end_uses][:district_heating][:interior_lighting] if existing_period[:end_uses][:district_heating].include?(:interior_lighting)
              existing_period[:end_uses][:district_heating][:exterior_lighting] += new_period[:end_uses][:district_heating][:exterior_lighting] if existing_period[:end_uses][:district_heating].include?(:exterior_lighting)
              existing_period[:end_uses][:district_heating][:interior_equipment] += new_period[:end_uses][:district_heating][:interior_equipment] if existing_period[:end_uses][:district_heating].include?(:interior_equipment)
              existing_period[:end_uses][:district_heating][:exterior_equipment] += new_period[:end_uses][:district_heating][:exterior_equipment] if existing_period[:end_uses][:district_heating].include?(:exterior_equipment)
              existing_period[:end_uses][:district_heating][:fans] += new_period[:end_uses][:district_heating][:fans] if existing_period[:end_uses][:district_heating].include?(:fans)
              existing_period[:end_uses][:district_heating][:pumps] += new_period[:end_uses][:district_heating][:pumps] if existing_period[:end_uses][:district_heating].include?(:pumps)
              existing_period[:end_uses][:district_heating][:heat_rejection] += new_period[:end_uses][:district_heating][:heat_rejection] if existing_period[:end_uses][:district_heating].include?(:heat_rejection)
              existing_period[:end_uses][:district_heating][:humidification] += new_period[:end_uses][:district_heating][:humidification] if existing_period[:end_uses][:district_heating].include?(:humidification)
              existing_period[:end_uses][:district_heating][:heat_recovery] += new_period[:end_uses][:district_heating][:heat_recovery] if existing_period[:end_uses][:district_heating].include?(:heat_recovery)
              existing_period[:end_uses][:district_heating][:water_systems] += new_period[:end_uses][:district_heating][:water_systems] if existing_period[:end_uses][:district_heating].include?(:water_systems)
              existing_period[:end_uses][:district_heating][:refrigeration] += new_period[:end_uses][:district_heating][:refrigeration] if existing_period[:end_uses][:district_heating].include?(:refrigeration)
              existing_period[:end_uses][:district_heating][:generators] += new_period[:end_uses][:district_heating][:generators] if existing_period[:end_uses][:district_heating].include?(:generators) 
            end

            if existing_period[:end_uses].include?(:water)
              existing_period[:end_uses][:water][:heating] += new_period[:end_uses][:water][:heating] if existing_period[:end_uses][:water].include?(:heating)
              existing_period[:end_uses][:water][:cooling] += new_period[:end_uses][:water][:cooling] if existing_period[:end_uses][:water].include?(:cooling)
              existing_period[:end_uses][:water][:interior_lighting] += new_period[:end_uses][:water][:interior_lighting] if existing_period[:end_uses][:water].include?(:interior_lighting)
              existing_period[:end_uses][:water][:exterior_lighting] += new_period[:end_uses][:water][:exterior_lighting] if existing_period[:end_uses][:water].include?(:exterior_lighting)
              existing_period[:end_uses][:water][:interior_equipment] += new_period[:end_uses][:water][:interior_equipment] if existing_period[:end_uses][:water].include?(:interior_equipment)
              existing_period[:end_uses][:water][:exterior_equipment] += new_period[:end_uses][:water][:exterior_equipment] if existing_period[:end_uses][:water].include?(:exterior_equipment)
              existing_period[:end_uses][:water][:fans] += new_period[:end_uses][:water][:fans] if existing_period[:end_uses][:water].include?(:fans)
              existing_period[:end_uses][:water][:pumps] += new_period[:end_uses][:water][:pumps] if existing_period[:end_uses][:water].include?(:pumps)
              existing_period[:end_uses][:water][:heat_rejection] += new_period[:end_uses][:water][:heat_rejection] if existing_period[:end_uses][:water].include?(:heat_rejection)
              existing_period[:end_uses][:water][:humidification] += new_period[:end_uses][:water][:humidification] if existing_period[:end_uses][:water].include?(:humidification)
              existing_period[:end_uses][:water][:heat_recovery] += new_period[:end_uses][:water][:heat_recovery] if existing_period[:end_uses][:water].include?(:heat_recovery)
              existing_period[:end_uses][:water][:water_systems] += new_period[:end_uses][:water][:water_systems] if existing_period[:end_uses][:water].include?(:water_systems)
              existing_period[:end_uses][:water][:refrigeration] += new_period[:end_uses][:water][:refrigeration] if existing_period[:end_uses][:water].include?(:refrigeration)
              existing_period[:end_uses][:water][:generators] += new_period[:end_uses][:water][:generators] if existing_period[:end_uses][:water].include?(:generators) 
            end

          end

          if existing_period.include?(:energy_production)
            if existing_periods[:energy_production].include?(:electricity_produced)
              existing_period[:energy_production][:electricity_produced][:photovoltaic] += new_period[:energy_production][:electricity_produced][:photovoltaic] if existing_period[:energy_production][:electricity_produced].include?(:photovoltaic)
            end
          end

          if existing_period.include?(:utility_costs)
            existing_period[:utility_costs][:fuel_type] += new_period[:utility_costs][:fuel_type] if existing_period[:utility_costs].include?(:fuel_type)
            existing_period[:utility_costs][:total_cost] += new_period[:utility_costs][:total_cost] if existing_period[:utility_costs].include?(:total_cost)
            existing_period[:utility_costs][:usage_cost] += new_period[:utility_costs][:usage_cost] if existing_period[:utility_costs].include?(:usage_cost)
            existing_period[:utility_costs][:demand_cost] += new_period[:utility_costs][:demand_cost] if existing_period[:utility_costs].include?(:demand_cost)
          end
          
          if existing_period.include?(:comfort_result)
            existing_period[:comfort_result][:time_setpoint_not_met_during_occupied_cooling] += new_period[:comfort_result][:time_setpoint_not_met_during_occupied_cooling] if existing_period[:comfort_result].include?(:time_setpoint_not_met_during_occupied_cooling)
            existing_period[:comfort_result][:time_setpoint_not_met_during_occupied_heating] += new_period[:comfort_result][:time_setpoint_not_met_during_occupied_heating] if existing_period[:comfort_result].include?(:time_setpoint_not_met_during_occupied_heating)
            existing_period[:comfort_result][:time_setpoint_not_met_during_occupied_hours] += new_period[:comfort_result][:time_setpoint_not_met_during_occupied_hours] if existing_period[:comfort_result].include?(:time_setpoint_not_met_during_occupied_hours)
          end         
                         
          return existing_period
         
        end
        
        def self.merge_reporting_periods(existing_periods, new_periods)
                    
          # TODO: match new periods to existing periods and call merge_reporting_period

          id_list_existing = []
          id_list_new = []
          id_list_existing = existing_periods.collect {|x| x[:id]}
          id_list_new = new_periods.collect {|x,y| x[:id]}

          puts "\nexisting periods ids: #{id_list_new}"
          puts "new periods ids: #{id_list_new}"

          puts "\nexisting periods: #{existing_periods}"
          puts "\nnew periods: #{new_periods}"

             
          existing_keys = get_all_keys(existing_periods)
          new_keys = get_all_keys(new_periods)
          
          if id_list_existing == id_list_new 
                
            existing_periods.each_index do |index|
              existing_keys = get_all_keys(existing_periods[index])
              new_keys = get_all_keys(new_periods[index])
              if new_keys == existing_keys
                # modify the existing_periods by merging the new periods results
                existing_periods[index] = merge_reporting_period(existing_periods[index], new_periods[index])
              else 
                raise "reperting periods with unidentical elements cannot be merged"
              end
            end

            # if existing periods are empty, take the new periods
          elsif existing_periods.empty?

            existing_periods = new_periods
            
            # if existing periods are empty, take the new periods
          else
            
            raise "cannot merge different reporting periods"

          end

          puts "\nfinal periods = #{existing_periods}"
          
          return existing_periods

        end
      end
    end
  end
end