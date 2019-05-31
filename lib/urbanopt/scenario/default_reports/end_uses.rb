
require 'urbanopt/scenario/default_reports/end_use'

class EndUses
    attr_accessor :electricity, :natural_gas, :additional_fuel, :district_cooling, :district_heating, :water

    def initialize(hash={})
        hash.delete_if {|k, v| v.nil?}
        hash = defaults.merge(hash)
               
        @electricity = EndUse.new
        @natural_gas = EndUse.new
        @additional_fuel = EndUse.new
        @district_cooling = EndUse.new
        @district_heating = EndUse.new
        @water = EndUse.new
    end


   #puts EndUse.new.to_hash

    def to_hash
        result = {}

        result[:electricity] = @electricity.to_hash
        result[:natural_gas] = @natural_gas.to_hash
        result[:additional_fuel] = @additional_fuel.to_hash
        result[:district_cooling] = @district_cooling.to_hash
        result[:district_heating] = @district_heating.to_hash
        result[:water] = @water.to_hash

        return result
    end

    def defaults
    
        hash = {}
        hash[:electricity] = EndUse.new.to_hash
        hash[:natural_gas] = EndUse.new.to_hash
        hash[:additional_fuel] = EndUse.new.to_hash
        hash[:district_cooling] = EndUse.new.to_hash
        hash[:district_heating] = EndUse.new.to_hash
        hash[:water] = EndUse.new.to_hash
        return hash
    
    end

    def merge_end_uses(existing_period, new_period)
                        
        # modify the existing_period by summing up the results ; # sum results only if they exist

        #if existing_period.end_uses.electricity
            existing_period.end_uses.electricity.heating += new_period.end_uses.electricity.heating #if existing_period.end_uses.electricity.heating
            existing_period.end_uses.electricity.cooling += new_period.end_uses.electricity.cooling if existing_period.end_uses.electricity.cooling
            existing_period.end_uses.electricity.interior_lighting += new_period.end_uses.electricity.interior_lighting if existing_period.end_uses.electricity.interior_lighting
            existing_period.end_uses.electricity.exterior_lighting += new_period.end_uses.electricity.exterior_lighting if existing_period.end_uses.electricity.exterior_lighting
            existing_period.end_uses.electricity.interior_equipment += new_period.end_uses.electricity.interior_equipment if existing_period.end_uses.electricity.interior_equipment
            existing_period.end_uses.electricity.exterior_equipment += new_period.end_uses.electricity.exterior_equipment if existing_period.end_uses.electricity.exterior_equipment
            existing_period.end_uses.electricity.fans += new_period.end_uses.electricity.fans if existing_period.end_uses.electricity.fans
            existing_period.end_uses.electricity.pumps += new_period.end_uses.electricity.pumps if existing_period.end_uses.electricity.pumps
            existing_period.end_uses.electricity.heat_rejection += new_period.end_uses.electricity.heat_rejection if existing_period.end_uses.electricity.heat_rejection
            existing_period.end_uses.electricity.humidification += new_period.end_uses.electricity.humidification if existing_period.end_uses.electricity.humidification
            existing_period.end_uses.electricity.heat_recovery += new_period.end_uses.electricity.heat_recovery if existing_period.end_uses.electricity.heat_recovery
            existing_period.end_uses.electricity.water_systems += new_period.end_uses.electricity.water_systems if existing_period.end_uses.electricity.water_systems
            existing_period.end_uses.electricity.refrigeration += new_period.end_uses.electricity.refrigeration if existing_period.end_uses.electricity.refrigeration
            existing_period.end_uses.electricity.generators += new_period.end_uses.electricity.generators if existing_period.end_uses.electricity.generators
          #end  

          # if existing_period[:end_uses].include?(:natural_gas)
          #   existing_period[:end_uses][:natural_gas][:heating] += new_period[:end_uses][:natural_gas][:heating] if existing_period[:end_uses][:natural_gas].include?(:heating)
          #   existing_period[:end_uses][:natural_gas][:cooling] += new_period[:end_uses][:natural_gas][:cooling] if existing_period[:end_uses][:natural_gas].include?(:cooling)
          #   existing_period[:end_uses][:natural_gas][:interior_lighting] += new_period[:end_uses][:natural_gas][:interior_lighting] if existing_period[:end_uses][:natural_gas].include?(:interior_lighting)
          #   existing_period[:end_uses][:natural_gas][:exterior_lighting] += new_period[:end_uses][:natural_gas][:exterior_lighting] if existing_period[:end_uses][:natural_gas].include?(:exterior_lighting)
          #   existing_period[:end_uses][:natural_gas][:interior_equipment] += new_period[:end_uses][:natural_gas][:interior_equipment] if existing_period[:end_uses][:natural_gas].include?(:interior_equipment)
          #   existing_period[:end_uses][:natural_gas][:exterior_equipment] += new_period[:end_uses][:natural_gas][:exterior_equipment] if existing_period[:end_uses][:natural_gas].include?(:exterior_equipment)
          #   existing_period[:end_uses][:natural_gas][:fans] += new_period[:end_uses][:natural_gas][:fans] if  existing_period[:end_uses][:natural_gas].include?(:fans)
          #   existing_period[:end_uses][:natural_gas][:pumps] += new_period[:end_uses][:natural_gas][:pumps] if existing_period[:end_uses][:natural_gas].include?(:pumps)
          #   existing_period[:end_uses][:natural_gas][:heat_rejection] += new_period[:end_uses][:natural_gas][:heat_rejection] if existing_period[:end_uses][:natural_gas].include?(:heat_rejection)
          #   existing_period[:end_uses][:natural_gas][:humidification] += new_period[:end_uses][:natural_gas][:humidification] if existing_period[:end_uses][:natural_gas].include?(:humidification)
          #   existing_period[:end_uses][:natural_gas][:heat_recovery] += new_period[:end_uses][:natural_gas][:heat_recovery] if existing_period[:end_uses][:natural_gas].include?(:heat_recovery)
          #   existing_period[:end_uses][:natural_gas][:water_systems] += new_period[:end_uses][:natural_gas][:water_systems] if existing_period[:end_uses][:natural_gas].include?(:water_systems)
          #   existing_period[:end_uses][:natural_gas][:refrigeration] += new_period[:end_uses][:natural_gas][:refrigeration] if  existing_period[:end_uses][:natural_gas].include?(:refrigeration)
          #   existing_period[:end_uses][:natural_gas][:generators] += new_period[:end_uses][:natural_gas][:generators] if existing_period[:end_uses][:natural_gas].include?(:generators) 
          # end

          # if existing_period[:end_uses].include?(:additional_fuel)
          #   existing_period[:end_uses][:additional_fuel][:heating] += new_period[:end_uses][:additional_fuel][:heating] if existing_period[:end_uses][:additional_fuel].include?(:heating)
          #   existing_period[:end_uses][:additional_fuel][:cooling] += new_period[:end_uses][:additional_fuel][:cooling] if existing_period[:end_uses][:additional_fuel].include?(:cooling)
          #   existing_period[:end_uses][:additional_fuel][:interior_lighting] += new_period[:end_uses][:additional_fuel][:interior_lighting] if existing_period[:end_uses][:additional_fuel].include?(:interior_lighting)
          #   existing_period[:end_uses][:additional_fuel][:exterior_lighting] += new_period[:end_uses][:additional_fuel][:exterior_lighting] if existing_period[:end_uses][:additional_fuel].include?(:exterior_lighting)
          #   existing_period[:end_uses][:additional_fuel][:interior_equipment] += new_period[:end_uses][:additional_fuel][:interior_equipment] if existing_period[:end_uses][:additional_fuel].include?(:interior_equipment)
          #   existing_period[:end_uses][:additional_fuel][:exterior_equipment] += new_period[:end_uses][:additional_fuel][:exterior_equipment] if existing_period[:end_uses][:additional_fuel].include?(:exterior_equipment)
          #   existing_period[:end_uses][:additional_fuel][:fans] += new_period[:end_uses][:additional_fuel][:fans] if existing_period[:end_uses][:additional_fuel].include?(:fans)
          #   existing_period[:end_uses][:additional_fuel][:pumps] += new_period[:end_uses][:additional_fuel][:pumps] if existing_period[:end_uses][:additional_fuel].include?(:pumps)
          #   existing_period[:end_uses][:additional_fuel][:heat_rejection] += new_period[:end_uses][:additional_fuel][:heat_rejection] if existing_period[:end_uses][:additional_fuel].include?(:heat_rejection)
          #   existing_period[:end_uses][:additional_fuel][:humidification] += new_period[:end_uses][:additional_fuel][:humidification] if existing_period[:end_uses][:additional_fuel].include?(:humidification)
          #   existing_period[:end_uses][:additional_fuel][:heat_recovery] += new_period[:end_uses][:additional_fuel][:heat_recovery] if existing_period[:end_uses][:additional_fuel].include?(:heat_recovery)
          #   existing_period[:end_uses][:additional_fuel][:water_systems] += new_period[:end_uses][:additional_fuel][:water_systems] if existing_period[:end_uses][:additional_fuel].include?(:water_systems)
          #   existing_period[:end_uses][:additional_fuel][:refrigeration] += new_period[:end_uses][:additional_fuel][:refrigeration] if existing_period[:end_uses][:additional_fuel].include?(:refrigeration)
          #   existing_period[:end_uses][:additional_fuel][:generators] += new_period[:end_uses][:additional_fuel][:generators] if existing_period[:end_uses][:additional_fuel].include?(:generators) 
          # end
          
          # if existing_period[:end_uses].include?(:district_cooling)
          #   existing_period[:end_uses][:district_cooling][:heating] += new_period[:end_uses][:district_cooling][:heating] if existing_period[:end_uses][:district_cooling].include?(:heating)
          #   existing_period[:end_uses][:district_cooling][:cooling] += new_period[:end_uses][:district_cooling][:cooling] if existing_period[:end_uses][:district_cooling].include?(:cooling)
          #   existing_period[:end_uses][:district_cooling][:interior_lighting] += new_period[:end_uses][:district_cooling][:interior_lighting] if existing_period[:end_uses][:district_cooling].include?(:interior_lighting)
          #   existing_period[:end_uses][:district_cooling][:exterior_lighting] += new_period[:end_uses][:district_cooling][:exterior_lighting] if existing_period[:end_uses][:district_cooling].include?(:exterior_lighting)
          #   existing_period[:end_uses][:district_cooling][:interior_equipment] += new_period[:end_uses][:district_cooling][:interior_equipment] if existing_period[:end_uses][:district_cooling].include?(:interior_equipment)
          #   existing_period[:end_uses][:district_cooling][:exterior_equipment] += new_period[:end_uses][:district_cooling][:exterior_equipment] if existing_period[:end_uses][:district_cooling].include?(:exterior_equipment)
          #   existing_period[:end_uses][:district_cooling][:fans] += new_period[:end_uses][:district_cooling][:fans] if existing_period[:end_uses][:district_cooling].include?(:fans)
          #   existing_period[:end_uses][:district_cooling][:pumps] += new_period[:end_uses][:district_cooling][:pumps] if existing_period[:end_uses][:district_cooling].include?(:pumps)
          #   existing_period[:end_uses][:district_cooling][:heat_rejection] += new_period[:end_uses][:district_cooling][:heat_rejection] if existing_period[:end_uses][:district_cooling].include?(:heat_rejection)
          #   existing_period[:end_uses][:district_cooling][:humidification] += new_period[:end_uses][:district_cooling][:humidification] if existing_period[:end_uses][:district_cooling].include?(:humidification)
          #   existing_period[:end_uses][:district_cooling][:heat_recovery] += new_period[:end_uses][:district_cooling][:heat_recovery] if existing_period[:end_uses][:district_cooling].include?(:heat_recovery)
          #   existing_period[:end_uses][:district_cooling][:water_systems] += new_period[:end_uses][:district_cooling][:water_systems] if existing_period[:end_uses][:district_cooling].include?(:water_systems)
          #   existing_period[:end_uses][:district_cooling][:refrigeration] += new_period[:end_uses][:district_cooling][:refrigeration] if existing_period[:end_uses][:district_cooling].include?(:refrigeration)
          #   existing_period[:end_uses][:district_cooling][:generators] += new_period[:end_uses][:district_cooling][:generators] if existing_period[:end_uses][:district_cooling].include?(:generators) 
          # end

          # if existing_period[:end_uses].include?(:district_heating)
          #   existing_period[:end_uses][:district_heating][:heating] += new_period[:end_uses][:district_heating][:heating] if existing_period[:end_uses][:district_heating].include?(:heating)
          #   existing_period[:end_uses][:district_heating][:cooling] += new_period[:end_uses][:district_heating][:cooling] if existing_period[:end_uses][:district_heating].include?(:cooling)
          #   existing_period[:end_uses][:district_heating][:interior_lighting] += new_period[:end_uses][:district_heating][:interior_lighting] if existing_period[:end_uses][:district_heating].include?(:interior_lighting)
          #   existing_period[:end_uses][:district_heating][:exterior_lighting] += new_period[:end_uses][:district_heating][:exterior_lighting] if existing_period[:end_uses][:district_heating].include?(:exterior_lighting)
          #   existing_period[:end_uses][:district_heating][:interior_equipment] += new_period[:end_uses][:district_heating][:interior_equipment] if existing_period[:end_uses][:district_heating].include?(:interior_equipment)
          #   existing_period[:end_uses][:district_heating][:exterior_equipment] += new_period[:end_uses][:district_heating][:exterior_equipment] if existing_period[:end_uses][:district_heating].include?(:exterior_equipment)
          #   existing_period[:end_uses][:district_heating][:fans] += new_period[:end_uses][:district_heating][:fans] if existing_period[:end_uses][:district_heating].include?(:fans)
          #   existing_period[:end_uses][:district_heating][:pumps] += new_period[:end_uses][:district_heating][:pumps] if existing_period[:end_uses][:district_heating].include?(:pumps)
          #   existing_period[:end_uses][:district_heating][:heat_rejection] += new_period[:end_uses][:district_heating][:heat_rejection] if existing_period[:end_uses][:district_heating].include?(:heat_rejection)
          #   existing_period[:end_uses][:district_heating][:humidification] += new_period[:end_uses][:district_heating][:humidification] if existing_period[:end_uses][:district_heating].include?(:humidification)
          #   existing_period[:end_uses][:district_heating][:heat_recovery] += new_period[:end_uses][:district_heating][:heat_recovery] if existing_period[:end_uses][:district_heating].include?(:heat_recovery)
          #   existing_period[:end_uses][:district_heating][:water_systems] += new_period[:end_uses][:district_heating][:water_systems] if existing_period[:end_uses][:district_heating].include?(:water_systems)
          #   existing_period[:end_uses][:district_heating][:refrigeration] += new_period[:end_uses][:district_heating][:refrigeration] if existing_period[:end_uses][:district_heating].include?(:refrigeration)
          #   existing_period[:end_uses][:district_heating][:generators] += new_period[:end_uses][:district_heating][:generators] if existing_period[:end_uses][:district_heating].include?(:generators) 
          # end

          # if existing_period[:end_uses].include?(:water)
          #   existing_period[:end_uses][:water][:heating] += new_period[:end_uses][:water][:heating] if existing_period[:end_uses][:water].include?(:heating)
          #   existing_period[:end_uses][:water][:cooling] += new_period[:end_uses][:water][:cooling] if existing_period[:end_uses][:water].include?(:cooling)
          #   existing_period[:end_uses][:water][:interior_lighting] += new_period[:end_uses][:water][:interior_lighting] if existing_period[:end_uses][:water].include?(:interior_lighting)
          #   existing_period[:end_uses][:water][:exterior_lighting] += new_period[:end_uses][:water][:exterior_lighting] if existing_period[:end_uses][:water].include?(:exterior_lighting)
          #   existing_period[:end_uses][:water][:interior_equipment] += new_period[:end_uses][:water][:interior_equipment] if existing_period[:end_uses][:water].include?(:interior_equipment)
          #   existing_period[:end_uses][:water][:exterior_equipment] += new_period[:end_uses][:water][:exterior_equipment] if existing_period[:end_uses][:water].include?(:exterior_equipment)
          #   existing_period[:end_uses][:water][:fans] += new_period[:end_uses][:water][:fans] if existing_period[:end_uses][:water].include?(:fans)
          #   existing_period[:end_uses][:water][:pumps] += new_period[:end_uses][:water][:pumps] if existing_period[:end_uses][:water].include?(:pumps)
          #   existing_period[:end_uses][:water][:heat_rejection] += new_period[:end_uses][:water][:heat_rejection] if existing_period[:end_uses][:water].include?(:heat_rejection)
          #   existing_period[:end_uses][:water][:humidification] += new_period[:end_uses][:water][:humidification] if existing_period[:end_uses][:water].include?(:humidification)
          #   existing_period[:end_uses][:water][:heat_recovery] += new_period[:end_uses][:water][:heat_recovery] if existing_period[:end_uses][:water].include?(:heat_recovery)
          #   existing_period[:end_uses][:water][:water_systems] += new_period[:end_uses][:water][:water_systems] if existing_period[:end_uses][:water].include?(:water_systems)
          #   existing_period[:end_uses][:water][:refrigeration] += new_period[:end_uses][:water][:refrigeration] if existing_period[:end_uses][:water].include?(:refrigeration)
          #   existing_period[:end_uses][:water][:generators] += new_period[:end_uses][:water][:generators] if existing_period[:end_uses][:water].include?(:generators) 
          # end
            
        return existing_period
        
    end

end

#test