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

require 'urbanopt/scenario/default_reports/extension'
require 'json-schema'
require 'json'

module URBANopt
  module Scenario
    module DefaultReports
      class Program 
        
        attr_accessor :site_area, :floor_area, :conditioned_area, :unconditioned_area, :footprint_area, :maximum_roof_height, 
        :maximum_number_of_stories, :maximum_number_of_stories_above_ground, :parking_area, :number_of_parking_spaces, 
        :number_of_parking_spaces_charging, :parking_footprint_area, :maximum_parking_height, :maximum_number_of_parking_stories, 
        :maximum_number_of_parking_stories_above_ground, :number_of_residential_units, :building_types, :building_type, :maximum_occupancy,
        :area, :window_area, :wall_area, :roof_area, :orientation, :aspect_ratio  
        
        # perform initialization functions
        def initialize(hash = {})
          #puts "HASHSHSHSHSHSHS IS +++++========= #{hash}"
          hash.delete_if {|k, v| v.nil?}
          hash = defaults.merge(hash)
          #hash = defaults

          @site_area = hash[:site_area]
          @floor_area = hash[:floor_area]
          @conditioned_area = hash[:conditioned_area]
          @unconditioned_area = hash[:unconditioned_area]
          @footprint_area = hash[:footprint_area]
          @maximum_roof_height = hash[:maximum_roof_height]
          @maximum_number_of_stories = hash[:maximum_number_of_stories]
          @maximum_number_of_stories_above_ground = hash[:maximum_number_of_stories_above_ground]
          @parking_area = hash[:parking_area]
          @number_of_parking_spaces = hash[:number_of_parking_spaces]
          @number_of_parking_spaces_charging = hash[:number_of_parking_spaces_charging]
          @parking_footprint_area = hash[:parking_footprint_area]
          @maximum_parking_height = hash[:maximum_parking_height]
          @maximum_number_of_parking_stories = hash[:maximum_number_of_parking_stories]
          @maximum_number_of_parking_stories_above_ground = hash[:maximum_number_of_parking_stories_above_ground]
          @number_of_residential_units = hash[:number_of_residential_units]
          @building_types = hash[:building_types]


          @window_area = hash[:window_area]
          @wall_area = hash[:wall_area]
          @roof_area = hash[:roof_area]
          @orientation = hash[:orientation]
          @aspect_ratio = hash[:aspect_ratio]

          # initialize class variable @@extension only once
          @@extension ||= Extension.new
          @@schema ||= @@extension.schema

        end
        
        def defaults
          hash = {}
          hash[:site_area] = 0
          hash[:floor_area] = 0
          hash[:conditioned_area] = 0
          hash[:unconditioned_area] = 0
          hash[:footprint_area] = 0
          hash[:maximum_roof_height] = 0
          hash[:maximum_number_of_stories] = 0
          hash[:maximum_number_of_stories_above_ground] = 0
          hash[:parking_area] = 0
          hash[:number_of_parking_spaces] = 0
          hash[:number_of_parking_spaces_charging] = 0
          hash[:parking_footprint_area] = 0
          hash[:maximum_parking_height] = 0
          hash[:maximum_number_of_parking_stories] = 0
          hash[:maximum_number_of_parking_stories_above_ground] = 0
          hash[:number_of_residential_units] = 0
          hash[:building_types] = [{:building_type => nil.to_s, :maximum_occupancy => nil.to_i , :floor_area => nil.to_i }]
          hash[:window_area] = {:north_window_area => 0, :south_window_area => 0, :east_window_area => 0, :west_window_area => 0, :total_window_area => 0}
          hash[:wall_area] = {:north_wall_area => 0, :south_wall_area => 0, :east_wall_area => 0, :west_wall_area => 0, :total_wall_area => 0}
          hash[:roof_area] = {:equipment_roof_area => 0, :photovoltaic_roof_area => 0, :available_roof_area => 0, :total_roof_area => 0}
          hash[:orientation] = 0
          hash[:aspect_ratio] = 0
          return hash
        end
        
        def to_hash
          result = {}
          result[:site_area] = @site_area if @site_area
          result[:floor_area] = @floor_area if @floor_area
          result[:conditioned_area] = @conditioned_area if @conditioned_area
          result[:unconditioned_area] = @unconditioned_area if @unconditioned_area
          result[:footprint_area] = @footprint_area if @footprint_area
          result[:maximum_roof_height] = @maximum_roof_height if @maximum_roof_height
          result[:maximum_number_of_stories] = @maximum_number_of_stories if @maximum_number_of_stories
          result[:maximum_number_of_stories_above_ground] = @maximum_number_of_stories_above_ground if @maximum_number_of_parking_stories_above_ground 
          result[:parking_area] = @parking_area if @parking_area 
          result[:number_of_parking_spaces] = @number_of_parking_spaces if @number_of_parking_spaces
          result[:number_of_parking_spaces_charging] = @number_of_parking_spaces_charging if @number_of_parking_spaces_charging
          result[:parking_footprint_area] = @parking_footprint_area if @parking_footprint_area
          result[:maximum_parking_height] = @maximum_parking_height if @maximum_parking_height
          result[:maximum_number_of_parking_stories] = @maximum_number_of_parking_stories if @maximum_number_of_parking_stories
          result[:maximum_number_of_parking_stories_above_ground] = @maximum_number_of_parking_stories_above_ground if @maximum_number_of_parking_stories_above_ground
          result[:number_of_residential_units] = @number_of_residential_units if @number_of_residential_units
          result[:building_types] = @building_types if @building_types 
          

          result[:window_area] = @window_area if @window_area
          result[:wall_area] = @wall_area if @wall_area
          result[:roof_area] = @roof_area if @roof_area 
          result[:orientation] = @orientation if @orientation
          result[:aspect_ratio] = @aspect_ratio if @aspect_ratio 

          # validate program properties against schema
          if @@extension.validate(@@schema[:definitions][:Program][:properties],result).any?
            raise "program properties does not match schema: #{@@extension.validate(@@schema[:definitions][:Program][:properties],result)}"
          end

          return result
        end
        
        def add_program(other)
          @site_area += other.site_area
          @floor_area += other.floor_area
          @conditioned_area += other.conditioned_area
          @unconditioned_area += other.unconditioned_area
          @footprint_area += other.footprint_area
          @maximum_roof_height += [@maximum_roof_height, other.maximum_roof_height].max
          
          @maximum_number_of_stories = [@maximum_number_of_stories, other.maximum_number_of_stories].max
          @maximum_number_of_stories_above_ground = [@maximum_number_of_stories_above_ground, other.maximum_number_of_stories_above_ground].max
         
          @parking_area += other.parking_area
          @number_of_parking_spaces += other.number_of_parking_spaces
          @number_of_parking_spaces_charging += other.number_of_parking_spaces_charging
          @parking_footprint_area += other.parking_footprint_area
          
          @maximum_parking_height = [@maximum_parking_height, other.maximum_parking_height].max
          @maximum_number_of_parking_stories = [@maximum_number_of_parking_stories, other.maximum_number_of_parking_stories].max
          @maximum_number_of_parking_stories_above_ground = [maximum_number_of_parking_stories_above_ground, other.maximum_number_of_parking_stories_above_ground].max
                   
          @number_of_residential_units += other.number_of_residential_units


          @building_types = other.building_types


          @window_area[:north_window_area] += other.window_area[:north_window_area]
          @window_area[:south_window_area] += other.window_area[:south_window_area]
          @window_area[:east_window_area] += other.window_area[:east_window_area]
          @window_area[:west_window_area] += other.window_area[:west_window_area]
          @window_area[:total_window_area] += other.window_area[:total_window_area]

          @wall_area[:north_wall_area] += other.wall_area[:north_wall_area]
          @wall_area[:south_wall_area] += other.wall_area[:south_wall_area]
          @wall_area[:east_wall_area] += other.wall_area[:east_wall_area]
          @wall_area[:west_wall_area] += other.wall_area[:west_wall_area]
          @wall_area[:total_wall_area] += other.wall_area[:total_wall_area]

          @roof_area[:equipment_roof_area] += other.roof_area[:equipment_roof_area]
          @roof_area[:photovoltaic_roof_area] += other.roof_area[:photovoltaic_roof_area]
          @roof_area[:available_roof_area] += other.roof_area[:available_roof_area]
          @roof_area[:total_roof_area] += other.roof_area[:total_roof_area]

        end
       
      end
    end
  end
end