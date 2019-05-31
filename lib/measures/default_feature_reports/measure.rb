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
    #result << OpenStudio::IdfObject.load("Output:Meter:MeterFileOnly,DistrictCooling:Facility,Timestep;").get

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
    
    # get building
    building = model.getBuilding

    #get surfaces
    surfaces = model.getSurfaces

    # get epwFile
    epwFile = runner.lastEpwFile
    if epwFile.empty?
      runner.registerError("Cannot find last epw file.")
      return false
    end
    epwFile = epwFile.get
    
    # create output report object
    feature_report = URBANopt::Scenario::DefaultReports::FeatureReport.new
    feature_report.id = feature_id
    feature_report.name = feature_name
    feature_report.feature_type = feature_type
    feature_report.directory_name = workflow.absoluteRunDir
    feature_report.timesteps_per_hour = model.getTimestep.numberOfTimestepsPerHour
    feature_report.simulation_status = 'Complete'

    feature_report.reporting_periods << URBANopt::Scenario::DefaultReports::ReportingPeriod.new


    # latitude
    latitude = epwFile.latitude
    puts "latitude = #{latitude}"
    #latitude = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='General' AND RowName='Latitude' AND ColumnName='Value'")
    #feature_report.location[:latitude] = latitude

    # longitude
    longitude = epwFile.longitude
    puts "longitude = #{longitude}"
    #longitude = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='General' AND RowName='Longitude' AND ColumnName='Value'")
    #feature_report.location[:longitude] = longitude

    # surface_elevation
    #elev = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='General' AND RowName='Elevation' AND ColumnName='Value'")
    #feature_report.location[:surfae_elevation] = elev

    #weather_filename
    # weather_file = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='General' AND RowName='Weather File' AND ColumnName='Value'")
    #feature_report.location[:weather_file] = weather_file


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

    # maximum_number_of_stories
    number_of_stories = building.standardsNumberOfStories.get if building.standardsNumberOfStories.is_initialized
    number_of_stories ||= 1
    puts "number of stories = #{number_of_stories}"
    feature_report.program.maximum_number_of_stories = number_of_stories

    # maximum_roof_height
    floor_to_floor_height = building.nominalFloortoFloorHeight.to_f ## why floor_to_floor_height = 0 !?
    puts "floor_to_floor_height = #{floor_to_floor_height}" 
    maximum_roof_height = number_of_stories * floor_to_floor_height
    feature_report.program.maximum_roof_height = maximum_roof_height

    # maximum_number_of_stories_above_ground
    number_of_stories_above_ground = building.standardsNumberOfAboveGroundStories.get if building.standardsNumberOfAboveGroundStories.is_initialized
    number_of_stories_above_ground ||= 1
    puts "number_of_stories_above_ground = #{number_of_stories_above_ground}"
    feature_report.program.maximum_number_of_stories_above_ground = number_of_stories_above_ground

    # maximum_number_of_parking_stories_above_ground
    ######need to add parking to model
    # parking_area
    ######need to add parking to model
    # number_of_parking_spaces
    ######need to add parking to model

    # number_of_parking_spaces_charging
    ######need to add parking to model

    # parking_footprint_area
    ######need to add parking to model

    # maximum_parking_height
    ######need to add parking to model

    # maximum_number_of_parking_stories
    ######need to add parking to model

    # number_of_residential_units
    number_of_living_units = building.standardsNumberOfLivingUnits.to_i.get if building.standardsNumberOfLivingUnits.is_initialized
    number_of_living_units ||= 1
    puts "number_of_residential_units = #{number_of_living_units}"
    feature_report.program.number_of_residential_units = number_of_living_units

    ### building_types
    ## building_type
    #building_type
    building_type = building.standardsBuildingType.to_s if building.standardsBuildingType.is_initialized
    building_type ||= nil
    feature_report.program.building_types[:building_type] = building_type
    #maximum_occupancy
    number_of_people = building.numberOfPeople
    puts "numeber_of_people = #{number_of_people}"
    feature_report.program.building_types[:maximum_occupancy] = number_of_people
    #floor_area
    floor_area = building.floorArea
    puts "total_floor_area = #{floor_area}"
    feature_report.program.building_types[:floor_area] = convert_units(floor_area, 'm^2', 'ft^2')
    
    ## window_area
    #north_window_area
    north_window_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Window Opening Area' AND ColumnName='North (315 to 45 deg)'").to_f
    feature_report.program.window_area[:north_window_area] = convert_units(north_window_area, 'm^2', 'ft^2')
    #south_window_area
    south_window_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Window Opening Area' AND ColumnName='South (135 to 225 deg)'").to_f
    feature_report.program.window_area[:south_window_area] = convert_units(south_window_area, 'm^2', 'ft^2')
    #east_window_area
    east_window_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Window Opening Area' AND ColumnName='East (45 to 135 deg)'").to_f
    feature_report.program.window_area[:east_window_area] = convert_units(east_window_area, 'm^2', 'ft^2')
    #west_window_area
    west_window_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Window Opening Area' AND ColumnName='West (225 to 315 deg)'").to_f
    feature_report.program.window_area[:west_window_area] = convert_units(west_window_area, 'm^2', 'ft^2')
    #total_window_area
    total_window_area = north_window_area + south_window_area + east_window_area + west_window_area
    feature_report.program.window_area[:total_window_area] = convert_units(total_window_area, 'm^2', 'ft^2')

    ## wall_area
    #north_wall_area
    north_wall_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='North (315 to 45 deg)'").to_f
    feature_report.program.wall_area[:north_wall_area] = convert_units(north_wall_area, 'm^2', 'ft^2')
    #south_wall_area
    south_wall_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='South (135 to 225 deg)'").to_f
    feature_report.program.wall_area[:south_wall_area] = convert_units(south_wall_area, 'm^2', 'ft^2')
    #east_wall_area
    east_wall_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='East (45 to 135 deg)'").to_f
    feature_report.program.wall_area[:east_wall_area] = convert_units(east_wall_area, 'm^2', 'ft^2')
    #west_wall_area
    west_wall_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='West (225 to 315 deg)'").to_f
    feature_report.program.wall_area[:west_wall_area] = convert_units(west_wall_area, 'm^2', 'ft^2')
    #total_wall_area
    total_wall_area = north_wall_area + south_wall_area + east_wall_area + west_wall_area
    feature_report.program.wall_area[:total_wall_area] = convert_units(total_wall_area, 'm^2', 'ft^2')


    ##roof_area
    #equipment_roof_area
    ######to be added
    #photovoltaic_roof_area

    #available_roof_area
    #available_roof_area = total_roof_area - equipment_roof_area

    #total_roof_area
    total_roof_area = 0.0
    surfaces.each do |surface|
      if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "RoofCeiling"
        total_roof_area += surface.netArea
      end
    end
    ####another way####
    #total_roof_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Skylight-Roof Ratio' AND RowName='Gross Roof Area' AND ColumnName='Total'").to_f
    feature_report.program.roof_area[:total_roof_area] = convert_units(total_roof_area, 'm^2', 'ft^2')
    puts total_roof_area

    #orientation
    #to check!   
    building_rotation = model.getBuilding.northAxis
    feature_report.program.orientation = building_rotation

    #aspect_ratio
    north_wall_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='North (315 to 45 deg)'")
    east_wall_area = sql_query(runner, sql_file, "InputVerificationandResultsSummary", "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='East (45 to 135 deg)'")
    aspect_ratio = north_wall_area / east_wall_area if north_wall_area != 0 && east_wall_area != 0
    aspect_ratio ||= nil
    feature_report.program.aspect_ratio = aspect_ratio

   
    ###########################################################################
    ### Construction Cost information

    ## category
    # category = sql_query(runner, sql_file, 'ObjectCountSummary', "TableName=")



    ## item_name

    # item_name = sql_query(runner, sql_file, )


    ## unit_cost

    ## cost_units

    ## item_quantity
    # if item_name == 'Wall' then
    #   item_quantity = sql_query(runner, sql_file, 'ObjectCountSummary')
    # end

    # if item_name == 'Floor' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Roof' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Internal Mass' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Building Detached Shading' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Fixed Detached Shading' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Window' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Door' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Glass Door' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Shading' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Overhang' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Fin' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Tubular Daylighting Device Dome' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # if item_name == 'Tubular Daylight Device Diffuser' then
    #   item_quantity = sql_query(runner, sql_file, '')
    # end

    # total_cost
    #loop over item_name and multiple unit_cost with item_quantity
    #total_cost = sql_file(runner,sql_file, "Life-Cycle Cost Report", "TableName='Present Value for' AND RowName='Total Site Energy' AND ColumnName='Total Energy'")
    
    # ###########################################################################
    # #### Reporting Periods information

    ### id

    ### name 

    ### multiplier

    ### start_date
    ## month
    begin_month = model.getRunPeriod.getBeginMonth
    feature_report.reporting_periods[0].start_date[:month] = begin_month
    ## day_of_month
    begin_day_of_month = model.getRunPeriod.getBeginDayOfMonth
    feature_report.reporting_periods[0].start_date[:day_of_month] = begin_day_of_month
    ## year
    begin_year = model.getYearDescription.calendarYear
    feature_report.reporting_periods[0].start_date[:year] = begin_year
   

    ### end_date
    ## month
    end_month = model.getRunPeriod.getEndMonth
    feature_report.reporting_periods[0].end_date[:month] = end_month
    ## day_of_month
    end_day_of_month = model.getRunPeriod.getEndDayOfMonth
    feature_report.reporting_periods[0].end_date[:day_of_month] = end_day_of_month
    ## year
    end_year = model.getYearDescription.calendarYear
    feature_report.reporting_periods[0].end_date[:year] = end_year


    
    ### total_site_energy
    total_site_energy = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Total Site Energy' AND ColumnName='Total Energy'")
    #puts "hello"
    #puts feature_report.reporting_periods[0]
    #puts feature_report.reporting_periods[0].class
    feature_report.reporting_periods[0].total_site_energy = convert_units(total_site_energy, 'GJ', 'kBtu')
    #feature_report.reporting_periods[0].total_site_energy = total_site_energy

    ### total_source_energy
    total_source_energy = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Total Source Energy' AND ColumnName='Total Energy'")
    feature_report.reporting_periods[0].total_source_energy = convert_units(total_source_energy, 'GJ', 'kBtu')
    
    ### net_site_energy
    net_site_energy = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Net Site Energy' AND ColumnName='Total Energy'")
    feature_report.reporting_periods[0].net_site_energy = convert_units(net_site_energy, 'GJ', 'kBtu')

    ### net_source_energy
    net_source_energy = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Site and Source Energy' AND RowName='Net Source Energy' AND ColumnName='Total Energy'")
    feature_report.reporting_periods[0].net_source_energy = convert_units(net_source_energy, 'GJ', 'kBtu')

    ### net_utility_cost
    #should be requested before simulation
    
    ### electricity
    electricity = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].electricity = convert_units(electricity, 'GJ', 'kBtu')

    ### natural_gas
    natural_gas = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].natural_gas = convert_units(natural_gas, 'GJ', 'kBtu')

    ### additional_fuel
    additional_fuel = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].additional_fuel = convert_units(additional_fuel, 'GJ', 'kBtu')
    
    ### district_cooling
    district_cooling = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].district_cooling = convert_units(district_cooling, 'GJ', 'kBtu')

    ### district_heating
    district_heating = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].district_heating = convert_units(district_heating, 'GJ', 'kBtu')

    ### water
    water = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='Water'")
    #feature_report.reporting_periods[0].water = convert_units(water, 'm3', 'ft3')
    feature_report.reporting_periods[0].water = water

    ### electricity_produced
    electricity_produced = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Electric Loads Satisfied' AND RowName='Total On-Site and Utility Electric Sources' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].electricity_produced = convert_units(electricity_produced, 'GJ', 'kBtu')

    ### end_uses
    ## electricity
      
    # electricity_heating  
    electricity_heating = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heating' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses.electricity.heating = convert_units(electricity_heating, 'GJ', 'kBtu')

    # electricity_cooling  
    electricity_cooling = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Cooling' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:cooling] = convert_units(electricity_cooling, 'GJ', 'kBtu')

    # electricity_interior_lighting  
    electricity_interior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Lighting' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:interior_lighting] = convert_units(electricity_interior_lighting, 'GJ', 'kBtu')

    # electricity_exterior_lighting  
    electricity_exterior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Lighting' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:exterior_lighting] = convert_units(electricity_exterior_lighting, 'GJ', 'kBtu')

    # electricity_interior_equipment
    electricity_interior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Equipment' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:interior_equipment] = convert_units(electricity_interior_equipment, 'GJ', 'kBtu')

    # electricity_exterior_equipment  
    electricity_exterior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Equipment' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:exterior_equipment] = convert_units(electricity_exterior_equipment, 'GJ', 'kBtu')

    # electricity_fans 
    electricity_fans = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Fans' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:fans] = convert_units(electricity_fans, 'GJ', 'kBtu')
    
    # electricity_pumps 
    electricity_pumps = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Pumps' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:pumps] = convert_units(electricity_pumps, 'GJ', 'kBtu')

    # electricity_heat_rejection 
    electricity_heat_rejection = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Rejection' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:heat_rejection] = convert_units(electricity_heat_rejection, 'GJ', 'kBtu')

    # electricity_humidification 
    electricity_humidification = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Humidification' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:humidification] = convert_units(electricity_humidification, 'GJ', 'kBtu')

    # electricity_heat_recovery 
    electricity_heat_recovery = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Recovery' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:heat_recovery] = convert_units(electricity_heat_recovery, 'GJ', 'kBtu')

    # electricity_water_systems 
    electricity_water_systems = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Water Systems' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:water_systems] = convert_units(electricity_water_systems, 'GJ', 'kBtu')

    # electricity_refrigeration
    electricity_refrigeration = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Refrigeration' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:refrigeration] = convert_units(electricity_refrigeration, 'GJ', 'kBtu')

    # electricity_generators 
    electricity_generators = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Generators' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].end_uses[:electricity][:generators] = convert_units(electricity_generators, 'GJ', 'kBtu')

    
    
    ## natural_gas
     
    # natural_gas_heating  
    natural_gas_heating = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heating' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:heating] = convert_units(natural_gas_heating, 'GJ', 'kBtu')
    
    # natural_gas_cooling  
    natural_gas_cooling = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Cooling' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:cooling] = convert_units(natural_gas_cooling, 'GJ', 'kBtu')

    # natural_gas_interior_lighting  
    natural_gas_interior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Lighting' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:interior_lighting] = convert_units(natural_gas_interior_lighting, 'GJ', 'kBtu')

    # natural_gas_exterior_lighting  
    natural_gas_exterior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Lighting' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:exterior_lighting] = convert_units(natural_gas_exterior_lighting, 'GJ', 'kBtu')

    # natural_gas_interior_equipment
    natural_gas_interior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Equipment' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:interior_equipment] = convert_units(natural_gas_interior_equipment, 'GJ', 'kBtu')

    # natural_gas_exterior_equipment  
    natural_gas_exterior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Equipment' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:exterior_equipment] = convert_units(natural_gas_exterior_equipment, 'GJ', 'kBtu')

    # natural_gas_fans 
    natural_gas_fans = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Fans' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:fans] = convert_units(natural_gas_fans, 'GJ', 'kBtu')
    
    # natural_gas_pumps 
    natural_gas_pumps = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Pumps' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:pumps] = convert_units(natural_gas_pumps, 'GJ', 'kBtu')

    # natural_gas_heat_rejection 
    natural_gas_heat_rejection = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Rejection' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:heat_rejection] = convert_units(natural_gas_heat_rejection, 'GJ', 'kBtu')

    # natural_gas_humidification 
    natural_gas_humidification = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Humidification' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:humidification] = convert_units(natural_gas_humidification, 'GJ', 'kBtu')

    # natural_gas_heat_recovery 
    natural_gas_heat_recovery = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Recovery' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:heat_recovery] = convert_units(natural_gas_heat_recovery, 'GJ', 'kBtu')

    # natural_gas_water_systems 
    natural_gas_water_systems = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Water Systems' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:water_systems] = convert_units(natural_gas_water_systems, 'GJ', 'kBtu')

    # natural_gas_refrigeration
    natural_gas_refrigeration = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Refrigeration' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:refrigeration] = convert_units(natural_gas_refrigeration, 'GJ', 'kBtu')

    # natural_gas_generators 
    natural_gas_generators = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Generators' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].end_uses[:natural_gas][:generators] = convert_units(natural_gas_generators, 'GJ', 'kBtu')


    ## additional_fuel
     
    # additional_fuel_heating  
    additional_fuel_heating = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heating' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:heating] = convert_units(additional_fuel_heating, 'GJ', 'kBtu')
    
    # additional_fuel_cooling  
    additional_fuel_cooling = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Cooling' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:cooling] = convert_units(additional_fuel_cooling, 'GJ', 'kBtu')

    # additional_fuel_interior_lighting  
    additional_fuel_interior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Lighting' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:interior_lighting] = convert_units(additional_fuel_interior_lighting, 'GJ', 'kBtu')

    # additional_fuel_exterior_lighting  
    additional_fuel_exterior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Lighting' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:exterior_lighting] = convert_units(additional_fuel_exterior_lighting, 'GJ', 'kBtu')

    # additional_fuel_interior_equipment
    additional_fuel_interior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Equipment' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:interior_equipment] = convert_units(additional_fuel_interior_equipment, 'GJ', 'kBtu')

    # additional_fuel_exterior_equipment  
    additional_fuel_exterior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Equipment' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:exterior_equipment] = convert_units(additional_fuel_exterior_equipment, 'GJ', 'kBtu')

    # additional_fuel_fans 
    additional_fuel_fans = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Fans' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:fans] = convert_units(additional_fuel_fans, 'GJ', 'kBtu')
    
    # additional_fuel_pumps 
    additional_fuel_pumps = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Pumps' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:pumps] = convert_units(additional_fuel_pumps, 'GJ', 'kBtu')

    # additional_fuel_heat_rejection 
    additional_fuel_heat_rejection = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Rejection' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:heat_rejection] = convert_units(additional_fuel_heat_rejection, 'GJ', 'kBtu')

    # additional_fuel_humidification 
    additional_fuel_humidification = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Humidification' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:humidification] = convert_units(additional_fuel_humidification, 'GJ', 'kBtu')

    # additional_fuel_heat_recovery 
    additional_fuel_heat_recovery = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Recovery' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:heat_recovery] = convert_units(additional_fuel_heat_recovery, 'GJ', 'kBtu')

    # additional_fuel_water_systems 
    additional_fuel_water_systems = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Water Systems' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:water_systems] = convert_units(additional_fuel_water_systems, 'GJ', 'kBtu')

    # additional_fuel_refrigeration
    additional_fuel_refrigeration = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Refrigeration' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:refrigeration] = convert_units(additional_fuel_refrigeration, 'GJ', 'kBtu')

    # additional_fuel_generators 
    additional_fuel_generators = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Generators' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].end_uses[:additional_fuel][:generators] = convert_units(additional_fuel_generators, 'GJ', 'kBtu')
    

    ## district_cooling
     
    # district_cooling_heating  
    district_cooling_heating = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heating' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:heating] = convert_units(district_cooling_heating, 'GJ', 'kBtu')
    
    # district_cooling_cooling  
    district_cooling_cooling = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Cooling' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:cooling] = convert_units(district_cooling_cooling, 'GJ', 'kBtu')

    # district_cooling_interior_lighting  
    district_cooling_interior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Lighting' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:interior_lighting] = convert_units(district_cooling_interior_lighting, 'GJ', 'kBtu')

    # district_cooling_exterior_lighting  
    district_cooling_exterior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Lighting' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:exterior_lighting] = convert_units(district_cooling_exterior_lighting, 'GJ', 'kBtu')

    # district_cooling_interior_equipment
    district_cooling_interior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Equipment' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:interior_equipment] = convert_units(district_cooling_interior_equipment, 'GJ', 'kBtu')

    # district_cooling_exterior_equipment  
    district_cooling_exterior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Equipment' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:exterior_equipment] = convert_units(district_cooling_exterior_equipment, 'GJ', 'kBtu')

    # district_cooling_fans 
    district_cooling_fans = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Fans' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:fans] = convert_units(district_cooling_fans, 'GJ', 'kBtu')
    
    # district_cooling_pumps 
    district_cooling_pumps = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Pumps' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:pumps] = convert_units(district_cooling_pumps, 'GJ', 'kBtu')

    # district_cooling_heat_rejection 
    district_cooling_heat_rejection = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Rejection' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:heat_rejection] = convert_units(district_cooling_heat_rejection, 'GJ', 'kBtu')

    # district_cooling_humidification 
    district_cooling_humidification = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Humidification' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:humidification] = convert_units(district_cooling_humidification, 'GJ', 'kBtu')

    # district_cooling_heat_recovery 
    district_cooling_heat_recovery = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Recovery' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:heat_recovery] = convert_units(district_cooling_heat_recovery, 'GJ', 'kBtu')

    # district_cooling_water_systems 
    district_cooling_water_systems = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Water Systems' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:water_systems] = convert_units(district_cooling_water_systems, 'GJ', 'kBtu')

    # district_cooling_refrigeration
    district_cooling_refrigeration = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Refrigeration' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:refrigeration] = convert_units(district_cooling_refrigeration, 'GJ', 'kBtu')

    # district_cooling_generators 
    district_cooling_generators = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Generators' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].end_uses[:district_cooling][:generators] = convert_units(district_cooling_generators, 'GJ', 'kBtu')


    ## district_heating
     
    # district_heating_heating  
    district_heating_heating = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heating' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:heating] = convert_units(district_heating_heating, 'GJ', 'kBtu')
    
    # district_heating_cooling  
    district_heating_cooling = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Cooling' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:cooling] = convert_units(district_heating_cooling, 'GJ', 'kBtu')

    # district_heating_interior_lighting  
    district_heating_interior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Lighting' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:interior_lighting] = convert_units(district_heating_interior_lighting, 'GJ', 'kBtu')

    # district_heating_exterior_lighting  
    district_heating_exterior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Lighting' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:exterior_lighting] = convert_units(district_heating_exterior_lighting, 'GJ', 'kBtu')

    # district_heating_interior_equipment
    district_heating_interior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Equipment' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:interior_equipment] = convert_units(district_heating_interior_equipment, 'GJ', 'kBtu')

    # district_heating_exterior_equipment  
    district_heating_exterior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Equipment' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:exterior_equipment] = convert_units(district_heating_exterior_equipment, 'GJ', 'kBtu')

    # district_heating_fans 
    district_heating_fans = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Fans' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:fans] = convert_units(district_heating_fans, 'GJ', 'kBtu')
    
    # district_heating_pumps 
    district_heating_pumps = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Pumps' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:pumps] = convert_units(district_heating_pumps, 'GJ', 'kBtu')

    # district_heating_heat_rejection 
    district_heating_heat_rejection = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Rejection' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:heat_rejection] = convert_units(district_heating_heat_rejection, 'GJ', 'kBtu')

    # district_heating_humidification 
    district_heating_humidification = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Humidification' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:humidification] = convert_units(district_heating_humidification, 'GJ', 'kBtu')

    # district_heating_heat_recovery 
    district_heating_heat_recovery = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Recovery' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:heat_recovery] = convert_units(district_heating_heat_recovery, 'GJ', 'kBtu')

    # district_heating_water_systems 
    district_heating_water_systems = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Water Systems' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:water_systems] = convert_units(district_heating_water_systems, 'GJ', 'kBtu')

    # district_heating_refrigeration
    district_heating_refrigeration = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Refrigeration' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:refrigeration] = convert_units(district_heating_refrigeration, 'GJ', 'kBtu')

    # district_heating_generators 
    district_heating_generators = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Generators' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].end_uses[:district_heating][:generators] = convert_units(district_heating_generators, 'GJ', 'kBtu')


    ## water
     
    # water_heating  
    water_heating = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heating' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:heating] = convert_units(water_heating, 'GJ', 'kBtu')
    
    # water_cooling  
    water_cooling = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Cooling' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:cooling] = convert_units(water_cooling, 'GJ', 'kBtu')

    # water_interior_lighting  
    water_interior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Lighting' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:interior_lighting] = convert_units(water_interior_lighting, 'GJ', 'kBtu')

    # water_exterior_lighting  
    water_exterior_lighting = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Lighting' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:exterior_lighting] = convert_units(water_exterior_lighting, 'GJ', 'kBtu')

    # water_interior_equipment
    water_interior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Interior Equipment' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:interior_equipment] = convert_units(water_interior_equipment, 'GJ', 'kBtu')

    # water_exterior_equipment  
    water_exterior_equipment = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Exterior Equipment' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:exterior_equipment] = convert_units(water_exterior_equipment, 'GJ', 'kBtu')

    # water_fans 
    water_fans = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Fans' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:fans] = convert_units(water_fans, 'GJ', 'kBtu')
    
    # water_pumps 
    water_pumps = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Pumps' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:pumps] = convert_units(water_pumps, 'GJ', 'kBtu')

    # water_heat_rejection 
    water_heat_rejection = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Rejection' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:heat_rejection] = convert_units(water_heat_rejection, 'GJ', 'kBtu')

    # water_humidification 
    water_humidification = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Humidification' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:humidification] = convert_units(water_humidification, 'GJ', 'kBtu')

    # water_heat_recovery 
    water_heat_recovery = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Heat Recovery' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:heat_recovery] = convert_units(water_heat_recovery, 'GJ', 'kBtu')

    # water_water_systems 
    water_water_systems = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Water Systems' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:water_systems] = convert_units(water_water_systems, 'GJ', 'kBtu')

    # water_refrigeration
    water_refrigeration = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Refrigeration' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:refrigeration] = convert_units(water_refrigeration, 'GJ', 'kBtu')

    # water_generators 
    water_generators = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='End Uses' AND RowName='Generators' AND ColumnName='Water'")
    feature_report.reporting_periods[0].end_uses[:water][:generators] = convert_units(water_generators, 'GJ', 'kBtu')

    ### energy_production
    ## electricity_produced
    # photovoltaic
    photovoltaic_power = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Electric Loads Satisfied' AND RowName='Photovoltaic Power' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].energy_production[:electricity_produced][:photovoltaic] = convert_units(photovoltaic_power, 'GJ', 'kBtu')

    ### utility_costs
    ## fuel_type

    ## total_cost

    ## usage_cost

    ## demand_cost
    

    ###comfort_result
    ## time_setpoint_not_met_during_occupied_cooling
    time_setpoint_not_met_during_occupied_cooling = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Comfort and Setpoint Not Met Summary' AND RowName='Time Setpoint Not Met During Occupied Cooling' AND ColumnName='Facility'")
    feature_report.reporting_periods[0].comfort_result[:time_setpoint_not_met_during_occupied_cooling] = time_setpoint_not_met_during_occupied_cooling

    ## time_setpoint_not_met_during_occupied_heating
    time_setpoint_not_met_during_occupied_heating = sql_query(runner, sql_file, "AnnualBuildingUtilityPerformanceSummary", "TableName='Comfort and Setpoint Not Met Summary' AND RowName='Time Setpoint Not Met During Occupied Heating' AND ColumnName='Facility'")
    feature_report.reporting_periods[0].comfort_result[:time_setpoint_not_met_during_occupied_heating] = time_setpoint_not_met_during_occupied_heating

    ## time_setpoint_not_met_during_occupied_hour
    time_setpoint_not_met_during_occupied_hours = time_setpoint_not_met_during_occupied_heating + time_setpoint_not_met_during_occupied_cooling
    feature_report.reporting_periods[0].comfort_result[:time_setpoint_not_met_during_occupied_hours] = time_setpoint_not_met_during_occupied_hours



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
    
    # add csv info to feature_report
    feature_report.timeseries_csv.path = File.join(Dir.pwd, "default_feature_reports.csv")
    feature_report.timeseries_csv.first_report_datetime = '0'
    feature_report.timeseries_csv.column_names = final_timeseries_names

    # Save the 'default_feature_reports.json' file
    hash = {}    
    hash[:feature_reports] = []
    hash[:feature_reports] << feature_report.to_hash

    File.open('default_feature_reports.json', 'w') do |f|
      f.puts JSON::pretty_generate(hash)
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
