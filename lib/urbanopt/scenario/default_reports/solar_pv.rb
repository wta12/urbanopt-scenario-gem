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
require 'json-schema'

module URBANopt
  module Scenario
    module DefaultReports
      ##
      # Onsite solar PV system attributes
      ##
      class SolarPV
        ##
        # _Float_ - power capacity in kilowatts
        #
        attr_accessor :size_kw

        ##
        # Initialize SolarPV attributes from a hash. Solar PV attributes currently are limited to power capacity.
        ##
        # [parameters:]
        #
        # * +hash+ - _Hash_ - A hash containting a +:size_kw+ key/value pair which represents the nameplate capacity in kilowatts (kW)
        #
        def initialize(hash = {})
          hash.delete_if { |k, v| v.nil? }

          @size_kw = hash[:size_kw]
          @id = hash[:id]

          # initialize class variables @@validator and @@schema
          @@validator ||= Validator.new
          @@schema ||= @@validator.schema

          # initialize @@logger
          @@logger ||= URBANopt::Scenario::DefaultReports.logger
        end

        ##
        # Convert to a Hash equivalent for JSON serialization
        ##
        def to_hash
          result = {}

          result[:size_kw] = @size_kw if @size_kw

          return result
        end

        ##
        # Merge PV systems
        ##
        def self.add_pv(existing_pv, new_pv)
          if existing_pv.size_kw.nil? && new_pv.size_kw.nil?
            existing_pv.size_kw = nil
          else
            existing_pv.size_kw = (existing_pv.size_kw || 0) + (new_pv.size_kw || 0)
          end

          return existing_pv
        end
      end
    end
  end
end
