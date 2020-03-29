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

require 'json'
require 'urbanopt/scenario/default_reports/validator'
require 'json-schema'

module URBANopt
  module Scenario
    module DefaultReports
      ##
      # power_distributio include eletrical power distribution systems information.
      ##
      class PowerDistribution
        attr_accessor :under_voltage_hours, :over_voltage_hours # :nodoc:
        ##
        # PowerDistrinution class intialize all power_distribution attributes:
        # +:under_voltage_hours+ , +:over_voltage_hours+
        ##
        # [parameters:]
        # +hash+ - _Hash_ - A hash which may contain a deserialized power_distribution.
        ##
        def initialize(hash = {})
          hash.delete_if { |k, v| v.nil? }
          hash = defaults.merge(hash)

          @under_voltage_hours = hash[:under_voltage_hours]
          @over_voltage_hours = hash[:over_voltage_hours]

          # initialize class variables @@validator and @@schema
          @@validator ||= Validator.new
          @@schema ||= @@validator.schema
        end

        ##
        # Assigns default values if attribute values do not exist.
        ##
        def defaults
          hash = {}
          hash[:under_voltage_hours] = nil
          hash[:over_voltage_hours] = nil

          return hash
        end

        ##
        # Converts to a Hash equivalent for JSON serialization.
        ##
        # - Exclude attributes with nil values.
        # - Validate power_distribution hash properties against schema.
        ##
        def to_hash
          result = {}
          result[:under_voltage_hours] = @under_voltage_hours if @under_voltage_hours
          result[:over_voltage_hours] = @over_voltage_hours if @over_voltage_hours

          # validate power_distribution properties against schema
          if @@validator.validate(@@schema[:definitions][:PowerDistribution][:properties], result).any?
            raise "power_distribution properties does not match schema: #{@@validator.validate(@@schema[:definitions][:PowerDistribution][:properties], result)}"
          end

          return result
        end

        ##
        # Merges muliple power distribution results together.
        ##
        # +new_costs+ - _Array_ - An array of ConstructionCost objects.
        def merge_power_distribition
          # method to be developed for any attributes to be aggregated or merged
        end
      end
    end
  end
end
