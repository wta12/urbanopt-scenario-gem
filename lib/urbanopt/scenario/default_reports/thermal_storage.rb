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
      # Ice Thermal Storage Systems
      ##
      class ThermalStorage
        ##
        # _Float_ - Total ice storage capacity on central plant loop in kWh
        #
        attr_accessor :its_size

        # _Float_ - Total ice storage capacity distributed to packaged systems in kWh
        #
        attr_accessor :ptes_size

        def initialize(hash = {})
          hash.delete_if { |k, v| v.nil? }

          @its_size = hash[:its_size]
          @ptes_size = hash[:ptes_size]

          # initialize class variables @@validator and @@schema
          @@validator ||= Validator.new
          @@schema ||= @@validator.schema

          # initialize @@logger
          @@logger ||= URBANopt::Scenario::DefaultReports.logger
        end

        ##
        # Assigns default values if attribute values do not exist.
        ##
        def defaults
          hash = {}
          hash[:its_size] = nil
          hash[:ptes_size] = nil

          return hash
        end

        ##
        # Convert to hash equivalent for JSON serialization
        ##
        def to_hash
          result = {}
          result[:its_size] = @its_size if @its_size
          result[:ptes_size] = @ptes_size if @ptes_size

          return result
        end

        ##
        # Add up old and new values
        ##
        def self.add_values(existing_value, new_value) #:nodoc:
          if existing_value && new_value
            existing_value += new_value
          elsif new_value
            existing_value = new_value
          end
          return existing_value
        end

        ##
        # Merge thermal storage
        ##
        def self.merge_thermal_storage(existing_tes, new_tes)
          existing_tes.its_size = add_values(existing_tes.its_size, new_tes.its_size)
          existing_tes.ptes_size = add_values(existing_tes.ptes_size, new_tes.ptes_size)

          return existing_tes
        end
      end
    end
  end
end
