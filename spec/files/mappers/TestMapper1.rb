require 'urbanopt/scenario'
require 'openstudio/common_measures'
require 'openstudio/model_articulation'

require 'json'

module URBANopt
  module Scenario
    class TestMapper1 < MapperBase
    
      # class level variables
      @@instance_lock = Mutex.new
      @@osw = nil
      @@geometry = nil
    
      def initialize()
      
        # do initialization of class variables in thread safe way
        @@instance_lock.synchronize do
          if @@osw.nil? 
            
            # load the OSW for this class
            osw_path = File.join(File.dirname(__FILE__), 'baseline.osw')
            File.open(osw_path, 'r') do |file|
              @@osw = JSON.parse(file.read, symbolize_names: true)
            end
        
            # add any paths local to the project
            @@osw[:file_paths] << File.join(File.dirname(__FILE__), '../weather/')
            
            # configures OSW with extension gem paths for measures and files, all extension gems must be 
            # required before this
            @@osw = OpenStudio::Extension.configure_osw(@@osw)
          end
        end
      end
      
      def create_osw(scenario, feature_id, feature_name)
      
        # do initialization of class variables in thread safe way
        @@instance_lock.synchronize do
          if @@geometry.nil? 
            
            # in a real example, geometry_file would be a GeoJSON or LadybugJSON
            geometry_file = scenario.geometry_file
            File.open(geometry_file, 'r') do |file|
              @@geometry = JSON.parse(file.read, symbolize_names: true)
            end
          end
        end
        
        # @@geometry would be a class that has methods to find a feature by id
        feature = nil
        @@geometry[:buildings].each do |building|
          if building[:id] == feature_id
            feature = building
            break
          end
        end
        
        raise "Cannot find feature '#{feature_id}' in '#{scenario.geometry_file}'" if feature.nil?
        
        # deep clone of @@osw before we configure it
        osw = Marshal.load(Marshal.dump(@@osw))
        
        # now we have the feature, we can look up its properties and set arguments in the OSW
        OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'total_bldg_floor_area', feature[:area])
        
        osw[:name] = feature_name
        osw[:description] = feature_name
        
        return osw
      end
      
    end
  end
end