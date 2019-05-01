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

require 'urbanopt/scenario/default_reports/feature_report'

#start the measure
class DefaultFeatureReports < OpenStudio::Measure::ReportingMeasure

  # human readable name
  def name
    return "DefaultFeatureReports"
  end

  # human readable description
  def description
    return "Writes default_feature_reports.json file used by URBANopt Scenario Default Post Processor"
  end

  # human readable description of modeling approach
  def modeler_description
    return "This measure only allows for one feature_report per simulation. If multiple features are simulated in a single simulation, a new measure must be written to disaggregate simulation results to multiple features."
  end

  # define the arguments that the user will input
  def arguments()
    args = OpenStudio::Measure::OSArgumentVector.new

    id = OpenStudio::Ruleset::OSArgument::makeStringArgument('feature_id', false)
    id.setDisplayName('Feature unique identifier')
    id.setDefaultValue('1')
    args << id
    
    name = OpenStudio::Ruleset::OSArgument::makeStringArgument('feature_name', false)
    name.setDisplayName('Feature scenario specific name')
    name.setDefaultValue('name')
    args << name
    
    feature_type = OpenStudio::Ruleset::OSArgument::makeStringArgument('feature_type', false)
    feature_type.setDisplayName('URBANopt Feature Type')
    feature_type.setDefaultValue('Building')
    args << feature_type
    
    return args
  end

  # return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    result = OpenStudio::IdfObjectVector.new

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(), user_arguments)
      return result
    end

    result << OpenStudio::IdfObject.load("Output:Meter:MeterFileOnly,Electricity:Facility,Timestep;").get
    result << OpenStudio::IdfObject.load("Output:Meter:MeterFileOnly,ElectricityProduced:Facility,Timestep;").get
    result << OpenStudio::IdfObject.load("Output:Meter:MeterFileOnly,Gas:Facility,Timestep;").get

    timeseries = ["District Cooling Chilled Water Rate", "District Cooling Mass Flow Rate",
                  "District Cooling Inlet Temperature", "District Cooling Outlet Temperature",
                  "District Heating Hot Water Rate", "District Heating Mass Flow Rate",
                  "District Heating Inlet Temperature", "District Heating Outlet Temperature"]

    timeseries.each do |ts|
      result << OpenStudio::IdfObject.load("Output:Variable,*,#{ts},Timestep;").get
    end

    return result
  end

  #sql_query method
  def sql_query(runner, sql, report_name, query)
    val = nil
    result = sql.execAndReturnFirstDouble("SELECT Value FROM TabularDataWithStrings WHERE ReportName='#{report_name}' AND #{query}")
    if result.empty?
      runner.registerWarning("Query failed for #{report_name} and #{query}")
    else
      begin
        val = result.get
      rescue
        val = nil
        runner.registerWarning("Query result.get failed")
      end
    end

    val
  end

  def convert_units(value, from_units, to_units)

    # apply unit conversion
    value_converted = OpenStudio::convert(value, from_units, to_units)
    if value_converted.is_initialized
      value = value_converted.get
    else
      @runner.registerError("Was not able to convert #{value} from #{from_units} to #{to_units}.")
      value = nil
    end

    return value
  end
  

  #define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    #use the built-in error checking
    unless runner.validateUserArguments(arguments, user_arguments)
      return false
    end

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(), user_arguments)
      return false
    end

    feature_id = runner.getStringArgumentValue('feature_id',user_arguments)
    feature_name = runner.getStringArgumentValue('feature_name',user_arguments)
    feature_type = runner.getStringArgumentValue('feature_type',user_arguments)

    # cache runner for this instance of the measure
    @runner = runner
    
    # get the WorkflowJSON object
    workflow = runner.workflow

    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError("Cannot find last model.")
      return false
    end
    model = model.get

    sql_file = runner.lastEnergyPlusSqlFile
    if sql_file.empty?
      runner.registerError("Cannot find last sql file.")
      return false
    end
    sql_file = sql_file.get
    model.setSqlFile(sql_file)
    
    # create output report object
    feature_report = URBANopt::Scenario::DefaultReports::FeatureReport.new
    feature_report.id = feature_id
    feature_report.name = feature_name
    feature_report.feature_type = feature_type
    feature_report.directory_name = workflow.absoluteRunDir
    feature_report.timesteps_per_hour = model.getTimestep.numberOfTimestepsPerHour
    feature_report.simulation_status = 'Complete'

    ###########################################################################
    # Program information

    # site_area
    # DLM: currently site area is not available (this would be the size of the lot the building is on)
    #feature_report.program.site_area = 0
    
    # floor_area
    floor_area = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Building Area' AND RowName='Total Building Area' AND ColumnName='Area'")
    feature_report.program.floor_area = convert_units(floor_area, 'm^2', 'ft^2')
    
    # conditioned_area
    conditioned_area = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Building Area' AND RowName='Net Conditioned Building Area' AND ColumnName='Area'")
    feature_report.program.conditioned_area = convert_units(conditioned_area, 'm^2', 'ft^2')

    # unconditioned_area
    unconditioned_area = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Building Area' AND RowName='Unconditioned Building Area' AND ColumnName='Area'")
    feature_report.program.unconditioned_area = convert_units(unconditioned_area, 'm^2', 'ft^2')
    
    # footprint_area
    # DLM: we can attach footprint_area to the building as an additional property, until then use floor_area
    # DLM: measures like the GeoJSON to OSM measure can set this value
    feature_report.program.footprint_area = convert_units(floor_area, 'm^2', 'ft^2')

    # ###########################################################################
    # # Other queries of interest

    # total_site_energy = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Total Site Energy' AND ColumnName='Total Energy'")
    # add_result(results, "total_site_energy", total_site_energy, "kBtu", "GJ")

    # net_site_energy = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Net Site Energy' AND ColumnName='Total Energy'")
    # add_result(results, "net_site_energy", net_site_energy, "kBtu", "GJ")

    # total_source_energy = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Total Source Energy' AND ColumnName='Total Energy'")
    # add_result(results, "total_source_energy", total_source_energy, "kBtu", "GJ")

    # net_source_energy = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Net Source Energy' AND ColumnName='Total Energy'")
    # add_result(results, "net_source_energy", net_source_energy, "kBtu", "GJ")

    # total_site_eui = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Total Site Energy' AND ColumnName='Energy Per Conditioned Building Area'")
    # add_result(results, "total_site_eui", total_site_eui, "kBtu/ft^2", "MJ/m^2")

    # total_source_eui = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Total Source Energy' AND ColumnName='Energy Per Conditioned Building Area'")
    # add_result(results, "total_source_eui", total_source_eui, "kBtu/ft^2", "MJ/m^2")

    # net_site_eui = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Net Site Energy' AND ColumnName='Energy Per Conditioned Building Area'")
    # add_result(results, "net_site_eui", net_site_eui, "kBtu/ft^2", "MJ/m^2")

    # net_source_eui = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Net Source Energy' AND ColumnName='Energy Per Conditioned Building Area'")
    # add_result(results, "net_source_eui", net_source_eui, "kBtu/ft^2", "MJ/m^2")

    # time_setpoint_not_met_during_occupied_heating = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Comfort and Setpoint Not Met Summary' AND RowName='Time Setpoint Not Met During Occupied Heating' AND ColumnName='Facility'")
    # add_result(results, "time_setpoint_not_met_during_occupied_heating", time_setpoint_not_met_during_occupied_heating, "hr")

    # time_setpoint_not_met_during_occupied_cooling = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Comfort and Setpoint Not Met Summary' AND RowName='Time Setpoint Not Met During Occupied Cooling' AND ColumnName='Facility'")
    # add_result(results, "time_setpoint_not_met_during_occupied_cooling", time_setpoint_not_met_during_occupied_cooling, "hr")

    # time_setpoint_not_met_during_occupied_hours = time_setpoint_not_met_during_occupied_heating + time_setpoint_not_met_during_occupied_cooling
    # add_result(results, "time_setpoint_not_met_during_occupied_hours", time_setpoint_not_met_during_occupied_hours, "hr")

    # window_to_wall_ratio_north = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Window-Wall Ratio' AND ColumnName='North (315 to 45 deg)'")
    # add_result(results, "window_to_wall_ratio_north", window_to_wall_ratio_north, "%")

    # window_to_wall_ratio_south = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Window-Wall Ratio' AND ColumnName='South (135 to 225 deg)'")
    # add_result(results, "window_to_wall_ratio_south", window_to_wall_ratio_south, "%")

    # window_to_wall_ratio_east = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Window-Wall Ratio' AND ColumnName='East (45 to 135 deg)'")
    # add_result(results, "window_to_wall_ratio_east", window_to_wall_ratio_east, "%")

    # window_to_wall_ratio_west = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Window-Wall Ratio' AND ColumnName='West (225 to 315 deg)'")
    # add_result(results, "window_to_wall_ratio_west", window_to_wall_ratio_west, "%")

    # lat = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='General' AND RowName='Latitude' AND ColumnName='Value'")
    # add_result(results, "latitude", lat, "deg")

    # long = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='General' AND RowName='Longitude' AND ColumnName='Value'")
    # add_result(results, "longitude", long, "deg")

    # elev = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='General' AND RowName='Elevation' AND ColumnName='Value'")
    # add_result(results, "elevation", elev, "ft", "m")

    # weather_file = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='General' AND RowName='Weather File' AND ColumnName='Value'")
    # add_result(results, "weather_file", weather_file, "deg")

    # energy_cost_total = sql_query(runner, sql_file, "LEEDsummary", "TableName='EAp2-7. Energy Cost Summary' AND RowName='Total' AND ColumnName='Total Energy Cost'")
    # add_result(results, "energy_cost_total", energy_cost_total, "$")

    # energy_cost_electricity = sql_query(runner, sql_file, "LEEDsummary", "TableName='EAp2-7. Energy Cost Summary' AND RowName='Electricity' AND ColumnName='Total Energy Cost'")
    # add_result(results, "energy_cost_electricity", energy_cost_electricity, "$")

    # energy_cost_natural_gas = sql_query(runner, sql_file, "LEEDsummary", "TableName='EAp2-7. Energy Cost Summary' AND RowName='Natural Gas' AND ColumnName='Total Energy Cost'")
    # add_result(results, "energy_cost_natural_gas", energy_cost_natural_gas, "$")

    # energy_cost_other = sql_query(runner, sql_file, "LEEDsummary", "TableName='EAp2-7. Energy Cost Summary' AND RowName='Other' AND ColumnName='Total Energy Cost'")
    # add_result(results, "energy_cost_other", energy_cost_other, "$")

    # # building_name = sql_query(runner, sql_file, "Initializationsummary", "TableName='Building Information' AND RowName='1' AND ColumnName='Building Name'")
    # # add_result(results, "building_name", building_name.to_s,building_name.to_s)

    # # queries with one-line API methods

    # timesteps_per_hour = model.getTimestep.numberOfTimestepsPerHour
    # add_result(results, "timesteps_per_hour", timesteps_per_hour, "")

    # begin_month = model.getRunPeriod.getBeginMonth
    # add_result(results, "begin_month", begin_month, "")

    # begin_day_of_month = model.getRunPeriod.getBeginDayOfMonth
    # add_result(results, "begin_day_of_month", begin_day_of_month, "")

    # end_month = model.getRunPeriod.getEndMonth
    # add_result(results, "end_month", end_month, "")

    # end_day_of_month = model.getRunPeriod.getEndDayOfMonth
    # add_result(results, "end_day_of_month", end_day_of_month, "")

    # begin_year = model.getYearDescription.calendarYear
    # if begin_year.is_initialized
      # add_result(results, "begin_year", begin_year.get, "")
    # end

    # building = model.getBuilding

    # building_rotation = building.northAxis
    # add_result(results, "orientation", building_rotation, "deg")

    # total_occupancy = building.numberOfPeople
    # num_units = 1
    # if building.standardsNumberOfLivingUnits.is_initialized
      # num_units = building.standardsNumberOfLivingUnits.get.to_i
    # end
    # add_result(results, "total_occupancy", total_occupancy * num_units, "people")

    # occupancy_density = building.peoplePerFloorArea
    # add_result(results, "occupant_density", occupancy_density, "people/ft^2", "people/m^2")

    # lighting_power = building.lightingPower
    # add_result(results, "lighting_power", lighting_power, "W")

    # lighting_power_density = building.lightingPowerPerFloorArea
    # add_result(results, "lighting_power_density", lighting_power_density, "W/ft^2", "W/m^2")

    # infiltration_rate = building.infiltrationDesignAirChangesPerHour
    # add_result(results, "infiltration_rate", infiltration_rate, "ACH")

    # number_of_floors = building.standardsNumberOfStories.get if building.standardsNumberOfStories.is_initialized
    # number_of_floors ||= nil
    # add_result(results, "number_of_floors", number_of_floors, "")

    # building_type = building.standardsBuildingType.to_s if building.standardsBuildingType.is_initialized
    # building_type ||= nil
    # add_result(results, "building_type", building_type, "")

    # building_name = model.getBuilding.name.to_s
    # add_result(results, "building_name", building_name, "")

    # #get exterior wall, exterior roof, and ground plate areas
    # exterior_wall_area = 0.0
    # exterior_roof_area = 0.0
    # ground_contact_area = 0.0
    # surfaces = model.getSurfaces
    # surfaces.each do |surface|
      # if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "Wall"
        # exterior_wall_area += surface.netArea
      # end
      # if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "RoofCeiling"
        # exterior_roof_area += surface.netArea
      # end
      # if surface.outsideBoundaryCondition == "Ground" and surface.surfaceType == "Floor"
        # ground_contact_area += surface.netArea
      # end
    # end

    # add_result(results, "exterior_wall_area", exterior_wall_area, "ft^2", "m^2")

    # add_result(results, "exterior_roof_area", exterior_roof_area, "ft^2", "m^2")

    # add_result(results, "ground_contact_area", ground_contact_area, "ft^2", "m^2")

    # #get exterior fenestration area
    # exterior_fenestration_area = 0.0
    # subsurfaces = model.getSubSurfaces
    # subsurfaces.each do |subsurface|
      # if subsurface.outsideBoundaryCondition == "Outdoors"
        # if subsurface.subSurfaceType == "FixedWindow" or subsurface.subSurfaceType == "OperableWindow"
          # exterior_fenestration_area += subsurface.netArea
        # end
      # end
    # end

    # add_result(results, "exterior_fenestration_area", exterior_fenestration_area, "ft^2", "m^2")

    # #get density of economizers in airloops
    # num_airloops = 0
    # num_economizers = 0
    # model.getAirLoopHVACs.each do |air_loop|
      # num_airloops += 1
      # if air_loop.airLoopHVACOutdoorAirSystem.is_initialized
        # air_loop_oa = air_loop.airLoopHVACOutdoorAirSystem.get
        # air_loop_oa_controller = air_loop_oa.getControllerOutdoorAir
        # if air_loop_oa_controller.getEconomizerControlType != "NoEconomizer"
          # num_economizers += 1
        # end
      # end
    # end
    # economizer_density = num_economizers / num_airloops if num_airloops != 0
    # economizer_density ||= nil

    # add_result(results, "economizer_density", economizer_density, "")

    # #get aspect ratios
    # north_wall_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='North (315 to 45 deg)'")
    # east_wall_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='East (45 to 135 deg)'")
    # aspect_ratio = north_wall_area / east_wall_area if north_wall_area != 0 && east_wall_area != 0
    # aspect_ratio ||= nil

    # add_result(results, "aspect_ratio", aspect_ratio, "")
    
    ###########################################################################
    # Timeseries

    # timeseries we want to report
    requested_timeseries_names = ["Electricity:Facility", "ElectricityProduced:Facility", "Gas:Facility", "DistrictCooling:Facility", "DistrictHeating:Facility", "District Cooling Chilled Water Rate", "District Cooling Mass Flow Rate", "District Cooling Inlet Temperature", "District Cooling Outlet Temperature", "District Heating Hot Water Rate", "District Heating Mass Flow Rate", "District Heating Inlet Temperature", "District Heating Outlet Temperature"]
             
    # number of values in each timeseries
    n = nil
    
    # all numeric timeseries values, transpose of CSV file (e.g. values[j] is column, values[j][i] is column and row)
    values = []

    # Since schedule value will have a bunch of key_values, we need to keep track of these as additional timeseries
    # this is recording the name of these final timeseries to write in the header of the CSV
    final_timeseries_names = []
    
    # loop over requested timeseries
    requested_timeseries_names.each_with_index do |timeseries_name, j|
 
      runner.registerInfo("TIMESERIES: #{timeseries_name}")

      # get all the key values that this timeseries can be reported for (e.g. if power is requested for each zone)
      key_values = sql_file.availableKeyValues("RUN PERIOD 1", "Zone Timestep", timeseries_name)
      runner.registerInfo("KEY VALUES: #{key_values}")
      if key_values.empty?
        key_values = [""]
      end
      
      # sort keys
      sorted_keys = key_values.sort
      requested_keys = ['SUMMED ELECTRICITY:FACILITY', 'SUMMED ELECTRICITY:FACILITY POWER', 'SUMMED ELECTRICITYPRODUCED:FACILITY', 'SUMMED ELECTRICITYPRODUCED:FACILITY POWER', 'SUMMED NET APPARENT POWER', 'SUMMED NET ELECTRIC ENERGY', 'SUMMED NET POWER', 'TRANSFORMER OUTPUT ELECTRIC ENERGY SCHEDULE']
      final_keys = []
      # make sure aggregated timeseries are listed in sorted order before all individual feature timeseries
      sorted_keys.each do |k|
        if requested_keys.include? k
          final_keys << k
        end
      end
      sorted_keys.each do |k|
        if !requested_keys.include? k
          final_keys << k
        end
      end

      # loop over final keys
      final_keys.each_with_index do |key_value, key_i|

        new_timeseries_name = ''

        runner.registerInfo("!! TIMESERIES NAME: #{timeseries_name} AND key_value: #{key_value}")

        # check if we have to come up with a new name for the timeseries in our CSV header
        if key_values.size == 1
          # use timeseries name when only 1 keyvalue
          new_timeseries_name = timeseries_name
        else
          # use key_value name
          # special case for Zone Thermal Comfort: use both timeseries_name and key_value
          if timeseries_name.include? 'Zone Thermal Comfort'
            new_timeseries_name = timeseries_name + ' ' + key_value
          else
            new_timeseries_name = key_value
          end
        end
        final_timeseries_names << new_timeseries_name

        # get the actual timeseries
        ts = sql_file.timeSeries("RUN PERIOD 1", "Zone Timestep", timeseries_name, key_value)

        if n.nil?
          # first timeseries should always be set
          runner.registerInfo("First timeseries")
          values[j] = ts.get.values
          n = values[j].size
        elsif ts.is_initialized
          runner.registerInfo('Is Initialized')
          values[j] = ts.get.values
        else
          runner.registerInfo('Is NOT Initialized')
          values[j] = Array.new(n, 0)
        end
      end
    end

    runner.registerInfo("new final_timeseries_names size: #{final_timeseries_names.size}")

    # Save the 'default_feature_reports.csv' file
    File.open("default_feature_reports.csv", 'w') do |file|
      file.puts(final_timeseries_names.join(','))
      (0...n).each do |i|
        line = []
        values.each_index do |j|
          line << values[j][i]
        end
        file.puts(line.join(','))
      end
    end

    #closing the sql file
    sql_file.close

    # Save the 'default_feature_reports.json' file
    hash = {}    
    hash[:feature_reports] = []
    hash[:feature_reports] << feature_report.to_hash

    File.open('default_feature_reports.json', 'w') do |f|
      f.puts JSON::fast_generate(hash)
      # make sure data is written to the disk one way or the other
      begin
        f.fsync
      rescue
        f.flush
      end
    end
    
    #reporting final condition
    runner.registerFinalCondition("Default Feature Reports generated successfully.")

    true

  end #end the run method

end #end the measure

# register the measure to be used by the application
DefaultFeatureReports.new.registerWithApplication
