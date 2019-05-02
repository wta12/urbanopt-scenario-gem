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
      class Program 
        
        attr_accessor :site_area, :floor_area, :conditioned_area, :unconditioned_area, :footprint_area
        
        # perform initialization functions
        def initialize(hash = {})
          hash.delete_if {|k, v| v.nil?}
          hash = defaults.merge(hash)

          @site_area = hash[:site_area]
          @floor_area = hash[:floor_area]
          @conditioned_area = hash[:conditioned_area]
          @unconditioned_area = hash[:unconditioned_area]
          @footprint_area = hash[:footprint_area]
        end
        
        def defaults
          hash = {}
          hash[:site_area] = 0
          hash[:floor_area] = 0
          hash[:conditioned_area] = 0
          hash[:unconditioned_area] = 0
          hash[:footprint_area] = 0
          return hash
        end
        
        def to_hash
          result = {}
          result[:site_area] = @site_area if @site_area
          result[:floor_area] = @floor_area if @floor_area
          result[:conditioned_area] = @conditioned_area if @conditioned_area
          result[:unconditioned_area] = @unconditioned_area if @unconditioned_area
          result[:footprint_area] = @footprint_area if @footprint_area
          return result
        end
        
        def add_program(other)
          @site_area += other.site_area
          @floor_area += other.floor_area
          @conditioned_area += other.conditioned_area
          @unconditioned_area += other.unconditioned_area
          @footprint_area += other.footprint_area
        end
       
      end
    end
  end
end