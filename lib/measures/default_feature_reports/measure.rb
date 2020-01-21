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

require 'urbanopt/scenario/default_reports/feature_report'
require 'csv'
require 'benchmark'
require 'logger'

@@logger = Logger.new(STDOUT)

# start the measure
class DefaultFeatureReports < OpenStudio::Measure::ReportingMeasure
  # human readable name
  def name
    return 'DefaultFeatureReports'
  end

  # human readable description
  def description
    return 'Writes default_feature_reports.json file used by URBANopt Scenario Default Post Processor'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This measure only allows for one feature_report per simulation. If multiple features are simulated in a single simulation, a new measure must be written to disaggregate simulation results to multiple features.'
  end

  # define the arguments that the user will input
  def arguments
    args = OpenStudio::Measure::OSArgumentVector.new

    id = OpenStudio::Measure::OSArgument.makeStringArgument('feature_id', false)
    id.setDisplayName('Feature unique identifier')
    id.setDefaultValue('1')
    args << id

    name = OpenStudio::Measure::OSArgument.makeStringArgument('feature_name', false)
    name.setDisplayName('Feature scenario specific name')
    name.setDefaultValue('name')
    args << name

    feature_type = OpenStudio::Measure::OSArgument.makeStringArgument('feature_type', false)
    feature_type.setDisplayName('URBANopt Feature Type')
    feature_type.setDefaultValue('Building')
    args << feature_type

    # make an argument for the frequency
    reporting_frequency_chs = OpenStudio::StringVector.new
    reporting_frequency_chs << 'Detailed'
    reporting_frequency_chs << 'Timestep'
    reporting_frequency_chs << 'Hourly'
    reporting_frequency_chs << 'Daily'
    # reporting_frequency_chs << "BillingPeriod" # match it to utility bill object
    ## Utility report here to report the start and end for each fueltype
    reporting_frequency_chs << 'Monthly'
    reporting_frequency_chs << 'Runperiod'

    reporting_frequency = OpenStudio::Measure::OSArgument.makeChoiceArgument('reporting_frequency', reporting_frequency_chs, true)
    reporting_frequency.setDisplayName('Reporting Frequency')
    reporting_frequency.setDescription('The frequency at which to report timeseries output data.')
    reporting_frequency.setDefaultValue('Hourly')
    args << reporting_frequency

    # move this in the run method
    if reporting_frequency.defaultValueDisplayName == 'BillingPeriod'
      @@logger.error('BillingPeriod frequency is not implemented yet')
    end

    return args
  end

  def fuel_types
    fuel_types = [
      'Electricity',
      'Gas',
      'AdditionalFuel',
      'DistrictCooling',
      'DistrictHeating',
      'Water'
    ]

    return fuel_types
  end

  def end_uses
    end_uses = [
      'Heating',
      'Cooling',
      'InteriorLights',
      'ExteriorLights',
      'InteriorEquipment',
      'ExteriorEquipment',
      'Fans',
      'Pumps',
      'HeatRejection',
      'Humidifier',
      'HeatRecovery',
      'WaterSystems',
      'Refrigeration',
      'Generators',
      'Facility'
    ]

    return end_uses
  end

  # return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  # rubocop:disable Naming/MethodName
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    result = OpenStudio::IdfObjectVector.new

    reporting_frequency = runner.getStringArgumentValue('reporting_frequency', user_arguments)

    # Request the output for each end use/fuel type combination
    end_uses.each do |end_use|
      fuel_types.each do |fuel_type|
        variable_name = if end_use == 'Facility'
                          "#{fuel_type}:#{end_use}"
                        else
                          "#{end_use}:#{fuel_type}"
                        end
        result << OpenStudio::IdfObject.load("Output:Meter,#{variable_name},#{reporting_frequency};").get
      end
    end

    ### Request the output for each end use/fuel type combination
    result << OpenStudio::IdfObject.load("Output:Meter:MeterFileOnly,Electricity:Facility,#{reporting_frequency};").get
    result << OpenStudio::IdfObject.load("Output:Meter:MeterFileOnly,ElectricityProduced:Facility,#{reporting_frequency};").get
    result << OpenStudio::IdfObject.load("Output:Meter:MeterFileOnly,Gas:Facility,#{reporting_frequency};").get
    result << OpenStudio::IdfObject.load("Output:Meter:MeterFileOnly,DistrictCooling:Facility,#{reporting_frequency};").get
    result << OpenStudio::IdfObject.load("Output:Meter:MeterFileOnly,DistrictHeating:Facility,#{reporting_frequency};").get

    timeseries_data = ['District Cooling Chilled Water Rate', 'District Cooling Mass Flow Rate',
                       'District Cooling Inlet Temperature', 'District Cooling Outlet Temperature',
                       'District Heating Hot Water Rate', 'District Heating Mass Flow Rate',
                       'District Heating Inlet Temperature', 'District Heating Outlet Temperature']

    timeseries_data.each do |ts|
      result << OpenStudio::IdfObject.load("Output:Variable,*,#{ts},#{reporting_frequency};").get
    end

    # use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return result
    end

    return result
  end

  # sql_query method
  def sql_query(runner, sql, report_name, query)
    val = nil
    result = sql.execAndReturnFirstDouble("SELECT Value FROM TabularDataWithStrings WHERE ReportName='#{report_name}' AND #{query}")
    if result.empty?
      runner.registerWarning("Query failed for #{report_name} and #{query}")
    else
      begin
        val = result.get
      rescue StandardError
        val = nil
        runner.registerWarning('Query result.get failed')
      end
    end

    val
  end

  # unit conversion method
  def convert_units(value, from_units, to_units)
    # apply unit conversion
    value_converted = OpenStudio.convert(value, from_units, to_units)
    if value_converted.is_initialized
      value = value_converted.get
    else
      @runner.registerError("Was not able to convert #{value} from #{from_units} to #{to_units}.")
      value = nil
    end
    return value
  end

  # define what happens when the measure is run
  # rubocop:disable Metrics/AbcSize
  def run(runner, user_arguments)
    super(runner, user_arguments)

    # use the built-in error checking
    unless runner.validateUserArguments(arguments, user_arguments)
      return false
    end

    # use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return false
    end

    feature_id = runner.getStringArgumentValue('feature_id', user_arguments)
    feature_name = runner.getStringArgumentValue('feature_name', user_arguments)
    feature_type = runner.getStringArgumentValue('feature_type', user_arguments)

    # Assign the user inputs to variables
    reporting_frequency = runner.getStringArgumentValue('reporting_frequency', user_arguments)

    # cache runner for this instance of the measure
    @runner = runner

    # get the WorkflowJSON object
    workflow = runner.workflow

    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    sql_file = runner.lastEnergyPlusSqlFile
    if sql_file.empty?
      runner.registerError('Cannot find last sql file.')
      return false
    end
    sql_file = sql_file.get
    model.setSqlFile(sql_file)

    # get building from model
    building = model.getBuilding

    # get surfaces from model
    surfaces = model.getSurfaces

    # get epw_file
    epw_file = runner.lastEpwFile
    if epw_file.empty?
      runner.registerError('Cannot find last epw file.')
      return false
    end
    epw_file = epw_file.get

    # create output feature_report report object
    feature_report = URBANopt::Scenario::DefaultReports::FeatureReport.new
    feature_report.id = feature_id
    feature_report.name = feature_name
    feature_report.feature_type = feature_type
    feature_report.directory_name = workflow.absoluteRunDir
    feature_report.timesteps_per_hour = model.getTimestep.numberOfTimestepsPerHour
    feature_report.simulation_status = 'Complete'

    feature_report.reporting_periods << URBANopt::Scenario::DefaultReports::ReportingPeriod.new

    ###########################################################################
    ##
    # Get Location information and store in the feature_report
    ##

    # latitude
    latitude = epw_file.latitude
    feature_report.location.latitude = latitude

    # longitude
    longitude = epw_file.longitude
    feature_report.location.longitude = longitude

    # surface_elevation
    elev = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='General' AND RowName='Elevation' AND ColumnName='Value'")
    feature_report.location.surface_elevation = elev

    ##########################################################################
    ##
    # Get program information and store in the feature_report
    ##

    # floor_area
    floor_area = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Building Area' AND RowName='Total Building Area' AND ColumnName='Area'")
    feature_report.program.floor_area = convert_units(floor_area, 'm^2', 'ft^2')

    # conditioned_area
    conditioned_area = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Building Area' AND RowName='Net Conditioned Building Area' AND ColumnName='Area'")
    feature_report.program.conditioned_area = convert_units(conditioned_area, 'm^2', 'ft^2')

    # unconditioned_area
    unconditioned_area = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Building Area' AND RowName='Unconditioned Building Area' AND ColumnName='Area'")
    feature_report.program.unconditioned_area = convert_units(unconditioned_area, 'm^2', 'ft^2')

    # footprint_area
    feature_report.program.footprint_area = convert_units(floor_area, 'm^2', 'ft^2')

    # maximum_number_of_stories
    number_of_stories = building.standardsNumberOfStories.get if building.standardsNumberOfStories.is_initialized
    number_of_stories ||= 1
    feature_report.program.maximum_number_of_stories = number_of_stories

    # maximum_roof_height
    floor_to_floor_height = building.nominalFloortoFloorHeight.to_f
    maximum_roof_height = number_of_stories * floor_to_floor_height
    feature_report.program.maximum_roof_height = maximum_roof_height

    # maximum_number_of_stories_above_ground
    number_of_stories_above_ground = building.standardsNumberOfAboveGroundStories.get if building.standardsNumberOfAboveGroundStories.is_initialized
    number_of_stories_above_ground ||= 1
    feature_report.program.maximum_number_of_stories_above_ground = number_of_stories_above_ground

    # number_of_residential_units
    number_of_living_units = building.standardsNumberOfLivingUnits.to_i.get if building.standardsNumberOfLivingUnits.is_initialized
    number_of_living_units ||= 1
    feature_report.program.number_of_residential_units = number_of_living_units

    ## building_types

    # get an array of the model spaces
    spaces = model.getSpaces

    # get array of model space types
    space_types = model.getSpaceTypes

    # create a hash for space_type_areas (spcace types as keys and their areas as values)
    space_type_areas = {}
    model.getSpaceTypes.each do |space_type|
      building_type = space_type.standardsBuildingType
      if building_type.empty?
        building_type = 'unknown'
      else
        building_type = building_type.get
      end
      space_type_areas[building_type] = 0 if space_type_areas[building_type].nil?
      space_type_areas[building_type] += convert_units(space_type.floorArea, 'm^2', 'ft^2')
    end

    # create a hash for space_type_occupancy (spcace types as keys and their occupancy as values)
    space_type_occupancy = {}
    spaces.each do |space|
      if space.spaceType.empty?
        raise 'space.spaceType is empty. Make sure spaces have a space type'
      else
        building_type = space.spaceType.get.standardsBuildingType
      end
      if building_type.empty?
        building_type = 'unknown'
      else
        building_type = building_type.get
      end
      space_type_occupancy[building_type] = 0 if space_type_occupancy[building_type].nil?
      space_type_occupancy[building_type] += space.numberOfPeople
    end

    # combine all in a building_types array
    building_types = []
    for i in 0..(space_type_areas.size - 1)
      building_types << { building_type: space_type_areas.keys[i], floor_area: space_type_areas.values[i], maximum_occupancy: space_type_occupancy.values[i] }
    end
    # add results to the feature report JSON
    feature_report.program.building_types = building_types

    ## window_area
    # north_window_area
    north_window_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Window Opening Area' AND ColumnName='North (315 to 45 deg)'").to_f
    feature_report.program.window_area[:north_window_area] = convert_units(north_window_area, 'm^2', 'ft^2')
    # south_window_area
    south_window_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Window Opening Area' AND ColumnName='South (135 to 225 deg)'").to_f
    feature_report.program.window_area[:south_window_area] = convert_units(south_window_area, 'm^2', 'ft^2')
    # east_window_area
    east_window_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Window Opening Area' AND ColumnName='East (45 to 135 deg)'").to_f
    feature_report.program.window_area[:east_window_area] = convert_units(east_window_area, 'm^2', 'ft^2')
    # west_window_area
    west_window_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Window Opening Area' AND ColumnName='West (225 to 315 deg)'").to_f
    feature_report.program.window_area[:west_window_area] = convert_units(west_window_area, 'm^2', 'ft^2')
    # total_window_area
    total_window_area = north_window_area + south_window_area + east_window_area + west_window_area
    feature_report.program.window_area[:total_window_area] = convert_units(total_window_area, 'm^2', 'ft^2')

    ## wall_area
    # north_wall_area
    north_wall_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='North (315 to 45 deg)'").to_f
    feature_report.program.wall_area[:north_wall_area] = convert_units(north_wall_area, 'm^2', 'ft^2')
    # south_wall_area
    south_wall_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='South (135 to 225 deg)'").to_f
    feature_report.program.wall_area[:south_wall_area] = convert_units(south_wall_area, 'm^2', 'ft^2')
    # east_wall_area
    east_wall_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='East (45 to 135 deg)'").to_f
    feature_report.program.wall_area[:east_wall_area] = convert_units(east_wall_area, 'm^2', 'ft^2')
    # west_wall_area
    west_wall_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='West (225 to 315 deg)'").to_f
    feature_report.program.wall_area[:west_wall_area] = convert_units(west_wall_area, 'm^2', 'ft^2')
    # total_wall_area
    total_wall_area = north_wall_area + south_wall_area + east_wall_area + west_wall_area
    feature_report.program.wall_area[:total_wall_area] = convert_units(total_wall_area, 'm^2', 'ft^2')

    # total_roof_area
    total_roof_area = 0.0
    surfaces.each do |surface|
      if (surface.outsideBoundaryCondition == 'Outdoors') && (surface.surfaceType == 'RoofCeiling')
        total_roof_area += surface.netArea
      end
    end
    feature_report.program.roof_area[:total_roof_area] = convert_units(total_roof_area, 'm^2', 'ft^2')

    # orientation
    # RK: a more robust method should be implemented to find orientation(finding main axis of the building using aspect ratio)
    building_rotation = model.getBuilding.northAxis
    feature_report.program.orientation = building_rotation

    # aspect_ratio
    north_wall_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='North (315 to 45 deg)'")
    east_wall_area = sql_query(runner, sql_file, 'InputVerificationandResultsSummary', "TableName='Window-Wall Ratio' AND RowName='Gross Wall Area' AND ColumnName='East (45 to 135 deg)'")
    aspect_ratio = north_wall_area / east_wall_area if north_wall_area != 0 && east_wall_area != 0
    aspect_ratio ||= nil
    feature_report.program.aspect_ratio = aspect_ratio

    ############################################################################
    ##
    # Get Reporting Periods information and store in the feature_report
    ##

    # start_date
    # month
    begin_month = model.getRunPeriod.getBeginMonth
    feature_report.reporting_periods[0].start_date.month = begin_month
    # day_of_month
    begin_day_of_month = model.getRunPeriod.getBeginDayOfMonth
    feature_report.reporting_periods[0].start_date.day_of_month = begin_day_of_month
    # year
    begin_year = model.getYearDescription.calendarYear
    feature_report.reporting_periods[0].start_date.year = begin_year

    # end_date
    # month
    end_month = model.getRunPeriod.getEndMonth
    feature_report.reporting_periods[0].end_date.month = end_month
    # day_of_month
    end_day_of_month = model.getRunPeriod.getEndDayOfMonth
    feature_report.reporting_periods[0].end_date.day_of_month = end_day_of_month
    # year
    end_year = model.getYearDescription.calendarYear
    feature_report.reporting_periods[0].end_date.year = end_year

    # total_site_energy
    total_site_energy = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Site and Source Energy' AND RowName='Total Site Energy' AND ColumnName='Total Energy'")
    feature_report.reporting_periods[0].total_site_energy = convert_units(total_site_energy, 'GJ', 'kBtu')

    # total_source_energy
    total_source_energy = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Site and Source Energy' AND RowName='Total Source Energy' AND ColumnName='Total Energy'")
    feature_report.reporting_periods[0].total_source_energy = convert_units(total_source_energy, 'GJ', 'kBtu')

    # net_site_energy
    net_site_energy = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Site and Source Energy' AND RowName='Net Site Energy' AND ColumnName='Total Energy'")
    feature_report.reporting_periods[0].net_site_energy = convert_units(net_site_energy, 'GJ', 'kBtu')

    # net_source_energy
    net_source_energy = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Site and Source Energy' AND RowName='Net Source Energy' AND ColumnName='Total Energy'")
    feature_report.reporting_periods[0].net_source_energy = convert_units(net_source_energy, 'GJ', 'kBtu')

    # electricity
    electricity = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].electricity = convert_units(electricity, 'GJ', 'kBtu')

    # natural_gas
    natural_gas = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='Natural Gas'")
    feature_report.reporting_periods[0].natural_gas = convert_units(natural_gas, 'GJ', 'kBtu')

    # additional_fuel
    additional_fuel = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='Additional Fuel'")
    feature_report.reporting_periods[0].additional_fuel = convert_units(additional_fuel, 'GJ', 'kBtu')

    # district_cooling
    district_cooling = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='District Cooling'")
    feature_report.reporting_periods[0].district_cooling = convert_units(district_cooling, 'GJ', 'kBtu')

    # district_heating
    district_heating = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='District Heating'")
    feature_report.reporting_periods[0].district_heating = convert_units(district_heating, 'GJ', 'kBtu')

    # water
    water = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='End Uses' AND RowName='Total End Uses' AND ColumnName='Water'")
    # feature_report.reporting_periods[0].water = convert_units(water, 'm3', 'ft3')
    feature_report.reporting_periods[0].water = water

    # electricity_produced
    electricity_produced = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Electric Loads Satisfied' AND RowName='Total On-Site and Utility Electric Sources' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].electricity_produced = convert_units(electricity_produced, 'GJ', 'kBtu')

    ## end_uses

    # get fuel type as listed in the sql file
    fuel_type = ['Electricity', 'Natural Gas', 'Additional Fuel', 'District Cooling', 'District Heating', 'Water']

    # get enduses as listed in the sql file
    enduses = ['Heating', 'Cooling', 'Interior Lighting', 'Exterior Lighting', 'Interior Equipment', 'Exterior Equipment', 'Fans', 'Pumps',
               'Heat Rejection', 'Humidification', 'Heat Recovery', 'Water Systems', 'Refrigeration', 'Generators']

    # loop through fuel types and enduses to fill in sql_query method
    fuel_type.each do |ft|
      enduses.each do |eu|
        sql_r = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='End Uses' AND RowName='#{eu}' AND ColumnName='#{ft}'")

        # report each query in its corresponding feature report obeject
        if ft.include? ' '
          x = ft.tr(' ', '_').downcase
          m = feature_report.reporting_periods[0].end_uses.send(x)
        else
          m = feature_report.reporting_periods[0].end_uses.send(ft.downcase)

        end

        if eu.include? ' '
          y = eu.tr(' ', '_').downcase
          m.send("#{y}=", convert_units(sql_r, 'GJ', 'kBtu'))
        else
          m.send("#{eu.downcase}=", convert_units(sql_r, 'GJ', 'kBtu'))
        end
      end
    end

    ### energy_production
    ## electricity_produced
    # photovoltaic
    photovoltaic_power = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Electric Loads Satisfied' AND RowName='Photovoltaic Power' AND ColumnName='Electricity'")
    feature_report.reporting_periods[0].energy_production[:electricity_produced][:photovoltaic] = convert_units(photovoltaic_power, 'GJ', 'kBtu')

    ## comfort_result
    # time_setpoint_not_met_during_occupied_cooling
    time_setpoint_not_met_during_occupied_cooling = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Comfort and Setpoint Not Met Summary' AND RowName='Time Setpoint Not Met During Occupied Cooling' AND ColumnName='Facility'")
    feature_report.reporting_periods[0].comfort_result[:time_setpoint_not_met_during_occupied_cooling] = time_setpoint_not_met_during_occupied_cooling

    # time_setpoint_not_met_during_occupied_heating
    time_setpoint_not_met_during_occupied_heating = sql_query(runner, sql_file, 'AnnualBuildingUtilityPerformanceSummary', "TableName='Comfort and Setpoint Not Met Summary' AND RowName='Time Setpoint Not Met During Occupied Heating' AND ColumnName='Facility'")
    feature_report.reporting_periods[0].comfort_result[:time_setpoint_not_met_during_occupied_heating] = time_setpoint_not_met_during_occupied_heating

    # time_setpoint_not_met_during_occupied_hour
    time_setpoint_not_met_during_occupied_hours = time_setpoint_not_met_during_occupied_heating + time_setpoint_not_met_during_occupied_cooling
    feature_report.reporting_periods[0].comfort_result[:time_setpoint_not_met_during_occupied_hours] = time_setpoint_not_met_during_occupied_hours

    ######################################## Reporting TImeseries Results FOR CSV File ######################################

    # Get the weather file run period (as opposed to design day run period)
    ann_env_pd = nil
    sql_file.availableEnvPeriods.each do |env_pd|
      env_type = sql_file.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new('WeatherRunPeriod')
          ann_env_pd = env_pd
        end
      end
    end

    if ann_env_pd == false
      runner.registerError("Can't find a weather runperiod, make sure you ran an annual simulation, not just the design days.")
      return false
    end

    # timeseries we want to report
    requested_timeseries_names = [
      'Electricity:Facility',
      'ElectricityProduced:Facility',
      'Gas:Facility',
      'DistrictCooling:Facility',
      'DistrictHeating:Facility',
      'District Cooling Chilled Water Rate',
      'District Cooling Mass Flow Rate',
      'District Cooling Inlet Temperature',
      'District Cooling Outlet Temperature',
      'District Heating Hot Water Rate',
      'District Heating Mass Flow Rate',
      'District Heating Inlet Temperature',
      'District Heating Outlet Temperature'
    ]

    # number of values in each timeseries
    n = nil

    # all numeric timeseries values, transpose of CSV file (e.g. values[j] is column, values[j][i] is column and row)
    values = []

    # Since schedule value will have a bunch of key_values, we need to keep track of these as additional timeseries
    # this is recording the name of these final timeseries to write in the header of the CSV
    final_timeseries_names = []

    # loop over requested timeseries
    # rubocop: disable Metrics/BlockLength
    requested_timeseries_names.each_with_index do |timeseries_name, j|
      runner.registerInfo("TIMESERIES: #{timeseries_name}")

      # get all the key values that this timeseries can be reported for (e.g. if power is requested for each zone)
      key_values = sql_file.availableKeyValues(ann_env_pd.to_s, reporting_frequency.to_s, timeseries_name)
      runner.registerInfo("KEY VALUES: #{key_values}")
      if key_values.empty?
        key_values = ['']
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
        ts = sql_file.timeSeries(ann_env_pd.to_s, reporting_frequency.to_s, timeseries_name, key_value)

        if n.nil?
          # first timeseries should always be set
          runner.registerInfo('First timeseries')
          values[j] = ts.get.values
          n = values[j].size
        elsif ts.is_initialized
          runner.registerInfo('Is Initialized')
          values[j] = ts.get.values
        else
          runner.registerInfo('Is NOT Initialized')
          values[j] = Array.new(n, 0)
        end

        # ##Unit conversion
        old_units = ts.get.units if ts.is_initialized
        new_units = case old_units.to_s
                      when 'J'
                        'kBtu'
                      when 'kWh'
                        'kBtu'
                      when 'm3'
                        'gal'
                    end

        # Unit conversion here
        os_vec = values[j]

        # loop through each value to retrieve it
        for i in 0..os_vec.length - 1
          unless new_units == old_units
            os_vec[i] = OpenStudio.convert(os_vec[i], old_units, new_units).get
          end
        end
      end
    end
    # rubocop: enable Metrics/BlockLength
    runner.registerInfo("new final_timeseries_names size: #{final_timeseries_names.size}")

    # Save the 'default_feature_reports.csv' file
    File.open('default_feature_reports.csv', 'w') do |file|
      file.puts(final_timeseries_names.join(','))
      (0...n).each do |l|
        line = []
        values.each_index do |j|
          line << values[j][l]
        end
        file.puts(line.join(','))
      end
    end

    # closing the sql file
    sql_file.close

    ############################# Adding timeseries_csv info to json report and saving CSV ################################
    # add csv info to feature_report
    feature_report.timeseries_csv.path = File.join(Dir.pwd, 'default_feature_reports.csv')
    feature_report.timeseries_csv.first_report_datetime = '0'
    feature_report.timeseries_csv.column_names = final_timeseries_names

    ##### Save the 'default_feature_reports.json' file

    feature_report_hash = feature_report.to_hash

    File.open('default_feature_reports.json', 'w') do |f|
      f.puts JSON.pretty_generate(feature_report_hash)
      # make sure data is written to the disk one way or the other
      begin
        f.fsync
      rescue StandardError
        f.flush
      end
    end

    # reporting final condition
    runner.registerFinalCondition('Default Feature Reports generated successfully.')

    true
    # end the run method
  end
  # end the measure
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Naming/MethodName

# register the measure to be used by the application
DefaultFeatureReports.new.registerWithApplication
