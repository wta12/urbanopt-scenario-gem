require 'openstudio/common_measures'
require 'openstudio/model_articulation'

require 'json'

module URBANopt
  module Scenario
    class TestMapper1
    
      def initialize()
        osw_path = File.join(File.dirname(__FILE__), 'baseline.osw')
        File.open(osw_path, 'r') do |file|
          @osw = JSON.parse(file.read, symbolize_names: true)
        end
        @osw[:file_paths] << File.join(File.dirname(__FILE__), '../weather/')
        @osw = OpenStudio::Extension.configure_osw(@osw)
      end
      
      def create_osw(scenario, feature_id, feature_name)
      
        geometry_file = scenario.geometry_file
        
        @osw[:name] = feature_name
        @osw[:description] = feature_name
        return @osw
      end
      
    end
  end
end