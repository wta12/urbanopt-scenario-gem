
require 'urbanopt/scenario/default_reports/end_use'

class EndUses
    attr_accessor :electricity, :natural_gas, :additional_fuel, :district_cooling, :district_heating, :water

    def initialize(hash = {})
        puts "RUNNING ENDUSES"
        puts "ENDUSES hash type is #{hash.class}"
        hash.delete_if {|k, v| v.nil?}
        hash = defaults.merge(hash)
               
        @electricity = EndUse.new(hash[:electricity])
        @natural_gas = EndUse.new(hash[:natural_gas])
        @additional_fuel = EndUse.new(hash[:additional_fuel])
        @district_cooling = EndUse.new(hash[:district_cooling])
        @district_heating = EndUse.new(hash[:district_heating])
        @water = EndUse.new(hash[:water])
        puts "ENDUSES STOPPED"
    end


    def to_hash
        result = {}
        puts "running enduses to_hash method"
        result[:electricity] = @electricity.to_hash
        result[:natural_gas] = @natural_gas.to_hash
        result[:additional_fuel] = @additional_fuel.to_hash
        result[:district_cooling] = @district_cooling.to_hash
        result[:district_heating] = @district_heating.to_hash
        result[:water] = @water.to_hash
        #puts "enduses to_hash method STOPPED "
        return result
    end

    def defaults
        puts "running enduses... defaults method"
        hash = {}
        hash[:electricity] = EndUse.new.to_hash
        puts "ELECTRIITY STOPPED "
        hash[:natural_gas] = EndUse.new.to_hash
        puts "NATURAL GAS STOPPED "
        hash[:additional_fuel] = EndUse.new.to_hash
        puts "ADDITIONAL FUEL STOPPED "
        hash[:district_cooling] = EndUse.new.to_hash
        puts "DISTRICT COOLING STOPPED "
        hash[:district_heating] = EndUse.new.to_hash
        puts "DISTRICT HEATING STOPPED "
        hash[:water] = EndUse.new.to_hash
        puts "WATER STOPPED "
        
        return hash
            
    end

    def merge_end_uses!(new_end_uses)
        puts "running enduses  merge_end_uses! method"              
        # modify the existing_period by summing up the results ; # sum results only if they exist

        @electricity.merge_end_use!(new_end_uses.electricity)
        @natural_gas.merge_end_use!(new_end_uses.natural_gas)
        @additional_fuel.merge_end_use!(new_end_uses.additional_fuel)
        @district_cooling.merge_end_use!(new_end_uses.district_cooling)
        @district_heating.merge_end_use!(new_end_uses.district_heating)
        #puts "merge_end_uses! method STOPPED" 
        return self
        
    end

end

