# URBANopt Scenario Schema

The URBANopt Scenario Gem includes functionality for defining scenarios, running simulations, and post-processing results.  An URBANopt Scenario describes a specific set of options to apply to each Feature in a FeatureFile (e.g. each GeoJSON Feature in an URBANopt GeoJSON File).  User defined SimulationMapper classes translate each Feature to a SimulationDir which is a directory containing simulation input files.  A ScenarioRunner is used to perform simulations for each SimulationDir.  Finally, a ScenarioPostProcessor can run on a Scenario to generate scenario level results.  The [URBANopt Scenario Gem Design Document](https://docs.google.com/document/d/1ExcGuHliaSvPlrYevAJTSV8XAtTQXz_KQqH3p4iQDwg/edit) describes the gem in more detail.  The [URBANopt Example Project](https://github.com/urbanopt/urbanopt-example-project) demonstrates how to use the URBANopt Scenario Gem to perform a scenario analysis.

## Reporting output units

**JSON Output Units**

- energy outputs: kbtu
- electricity dispatches: kWh
- water rate outputs : GPM (gallon per minute)
- mass flow rate outputs : lbs/min
- Temperature outputs : &deg;F
- area output: sf
- measured distance output: ft
- cost outputs: $

**CSV Output Units**

|            output                        |  unit   |
| -----------------------------------------| ------- |
| Electricity:Facility                     | kWh     |
| ElectricityProduced:Facility             | kWh     |
| Electricity:Grid:Total				   | kWh     |
| Electricity:Grid:ToLoad                  | kWh     |
| Electricity:Grid:ToBattery               | kWh     |
| Electricity:Storage:ToLoad               | kWh     |
| Electricity:Storage:ToGrid               | kWh     |
| Electricity:Storage:StateOfCharge        | kWh     |
| ElectricityProduced:Generator:Total      | kWh     |
| ElectricityProduced:Generator:ToBattery  | kWh     |
| ElectricityProduced:Generator:ToLoad     | kWh     |
| ElectricityProduced:Generator:ToGrid     | kWh     |
| ElectricityProduced:PV:Total             | kWh     |
| ElectricityProduced:PV:ToBattery         | kWh     |
| ElectricityProduced:PV:ToLoad            | kWh     |
| ElectricityProduced:PV:ToGrid            | kWh     |
| ElectricityProduced:Wind:Total           | kWh     |
| ElectricityProduced:Wind:ToBattery       | kWh     |
| ElectricityProduced:Wind:ToLoad          | kWh     |
| ElectricityProduced:Wind:ToGrid          | kWh     |
| Gas:Facility                             | kbtu    |
| DistrictCooling:Facility                 | kbtu    |
| DistrictHeating:Facility                 | kbtu    |
| District Cooling Chilled Water Rate      | GPM     |
| District Cooling Mass Flow Rate          | lbs/min |
| District Cooling Inlet Temperature       | &deg;F  |
| District Cooling Outlet Temperature      | &deg;F  |
| District Heating Hot Water Rate          | GPM     |
| District Heating Mass Flow Rate          | lbs/min |
| District Heating Inlet Temperature       | &deg;F  |
| District Heating Outlet Temperature      | &deg;F  |
| Electricity:Grid:ToLoad                  | kWh.    |






















