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

require 'urbanopt/scenario/default_reports/end_use'
require 'urbanopt/scenario/default_reports/extension'
require 'json-schema'

module URBANopt
    module Scenario
        module DefaultReports
            class EndUses
                attr_accessor :electricity, :natural_gas, :additional_fuel, :district_cooling, :district_heating, :water

                def initialize(hash = {})
                    hash.delete_if {|k, v| v.nil?}
                    hash = defaults.merge(hash)
                        
                    @electricity = EndUse.new(hash[:electricity])
                    @natural_gas = EndUse.new(hash[:natural_gas])
                    @additional_fuel = EndUse.new(hash[:additional_fuel])
                    @district_cooling = EndUse.new(hash[:district_cooling])
                    @district_heating = EndUse.new(hash[:district_heating])
                    @water = EndUse.new(hash[:water])
                    
                    # initialize class variable @@extension only once
                    @@extension ||= Extension.new
                    @@schema ||= @@extension.schema

                end


                def to_hash
                    result = {}
                    result[:electricity] = @electricity.to_hash
                    result[:natural_gas] = @natural_gas.to_hash
                    result[:additional_fuel] = @additional_fuel.to_hash
                    result[:district_cooling] = @district_cooling.to_hash
                    result[:district_heating] = @district_heating.to_hash
                    result[:water] = @water.to_hash

                    # validate end_uses properties against schema
                    if @@extension.validate(@@schema[:definitions][:EndUses][:properties],result).any?
                    raise "end_uses properties does not match schema: #{@@extension.validate(@@schema[:definitions][:EndUses][:properties],result)}"
                    end


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

                def merge_end_uses!(new_end_uses)
                            
                    # modify the existing_period by summing up the results ; # sum results only if they exist
                    @electricity.merge_end_use!(new_end_uses.electricity)
                    @natural_gas.merge_end_use!(new_end_uses.natural_gas)
                    @additional_fuel.merge_end_use!(new_end_uses.additional_fuel)
                    @district_cooling.merge_end_use!(new_end_uses.district_cooling)
                    @district_heating.merge_end_use!(new_end_uses.district_heating)
                    return self
                    
                end

            end

        end
    end
end