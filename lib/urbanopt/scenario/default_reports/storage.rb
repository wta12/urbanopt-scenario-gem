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
      # Onsite storage system attributes
      ##
      class Storage
        ##
        # _Float_ - power capacity in kilowatts
        #
        attr_accessor :size_kw

        ##
        # _Float_ - storage capacity in kilowatt-hours
        #
        attr_accessor :size_kwh

        ##
        # Initialize Storage attributes from a hash. Storage attributes currently are limited to power and storage capacity.
        ##
        # [parameters:]
        #
        # * +hash+ - _Hash_ - A hash containting +:size_kw+ and +:size_kwh+ key/value pair which represents the power and storage capacity in kilowatts (kW) and kilowatt-hours respectively.
        #
        def initialize(hash = {})
          hash.delete_if { |k, v| v.nil? }

          @size_kw = hash[:size_kw]
          @size_kwh = hash[:size_kwh]

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
          result[:size_kwh] = @size_kwh if @size_kwh

          return result
        end

        ##
        # Merge Storage systems
        ##
        def self.add_storage(existing_storage, new_storage)
          if existing_storage.size_kw.nil?
            existing_storage.size_kw = new_storage.size_kw
          else
            existing_storage.size_kw = (existing_storage.size_kw || 0) + (new_storage.size_kw || 0)
          end

          if existing_storage.size_kw.nil?
            existing_storage.size_kwh = new_storage.size_kwh
          else
            existing_storage.size_kwh = (existing_storage.size_kwh || 0) + (new_storage.size_kwh || 0)
          end

          return existing_storage
        end
      end
    end
  end
end
