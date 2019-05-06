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

        # perform initialization functions
        def initialize(hash = {})
          hash.delete_if {|k, v| v.nil?}
          hash = defaults.merge(hash)
          
        end
                
        def defaults
          hash = {}
          return hash
        end
        
        def to_hash
          result = {}
          return result
        end
        
        def self.merge_reporting_period(existing_period, new_period)
          result = existing_period
          
          # TODO: merge existing period with new period
          
          return result
        end
        
        def self.merge_reporting_periods(existing_periods, new_periods)
          result = existing_periods
          
          # TODO: match new periods to existing periods and call merge_reporting_period
          
          return result
        end
        
      end
    end
  end
end