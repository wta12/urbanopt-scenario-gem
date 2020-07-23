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

require 'csv'
require 'date'
require 'json'
require 'fileutils'


module URBANopt
  module Scenario
    class ResultVisualization
      
      def self.create_visualization(root_dir)
        run_dir = File.join(root_dir, 'run')

        @all_scenario_results = []
        Dir.foreach(run_dir) do |folder|
          next if folder == '.' or folder == '..' or folder == 'scenarioData.js' or folder == 'scenario_comparison.html'
          scenario_dir = File.join(run_dir, folder)
          scenario_csv_dir = File.join(scenario_dir,'default_scenario_report.csv')
          scenario_name = folder.delete_suffix('_scenario')
          
          if File.exist?(scenario_csv_dir)
            headers = CSV.open(scenario_csv_dir, &:readline)
            size = CSV.open(scenario_csv_dir).readlines.size
            
            monthly_values = {}
            monthly_totals = {}
            annual_values = {}

            headers.each do |header|
              monthly_values[header] = []
            end
            
            i = 0
            CSV.foreach(scenario_csv_dir).map do |row|
              if i == 0
                # store header values from csv
                headers = row
                headers.each do |header|
                  monthly_values[header] = []
                end
                # store values from csv for each row
              elsif i <= size
                headers.each_index do |j|
                  monthly_values[headers[j]] << row[j]
                end
              end
              i += 1
            end

            if monthly_values["Datetime"][0].split(/\W+/)[0].to_f > 31
              format = "%Y/%m/%d %H:%M"
              year = monthly_values["Datetime"][0].split(/\W+/)[0]
            else
              format = "%m/%d/%Y %H:%M"
              year = monthly_values["Datetime"][0].split(/\W+/)[2]
            end

            # create dates for each month
            jan_date = DateTime.new(year.to_i, 1, 1, 1, 0)
            feb_date = DateTime.new(year.to_i, 2, 1, 0, 0)
            mar_date = DateTime.new(year.to_i, 3, 1, 0, 0)
            apr_date = DateTime.new(year.to_i, 4, 1, 0, 0)
            may_date = DateTime.new(year.to_i, 5, 1, 0, 0)
            jun_date = DateTime.new(year.to_i, 6, 1, 0, 0)
            jul_date = DateTime.new(year.to_i, 7, 1, 0, 0)
            aug_date = DateTime.new(year.to_i, 8, 1, 0, 0)
            sep_date = DateTime.new(year.to_i, 9, 1, 0, 0)
            oct_date = DateTime.new(year.to_i, 10, 1, 0, 0)
            nov_date = DateTime.new(year.to_i, 11, 1, 0, 0)
            dec_date = DateTime.new(year.to_i, 12, 1, 0, 0)
            jan_next_year = DateTime.new(year.to_i + 1, 1, 1, 0, 0)

            monthly_values["Datetime"].each do |i|
              date_obj = DateTime.strptime(i.to_s, format)
              index = monthly_values["Datetime"].index(i)

              # store index of each date from the csv
              if jan_date == date_obj
                @@jan_index = index
              elsif feb_date == date_obj
                @@feb_index = index
              elsif mar_date == date_obj
                @@mar_index = index
              elsif apr_date == date_obj
                @@apr_index = index
              elsif may_date == date_obj
                @@may_index = index
              elsif jun_date == date_obj
                @@jun_index = index
              elsif jul_date == date_obj
                @@jul_index = index
              elsif aug_date == date_obj
                @@aug_index = index
              elsif sep_date == date_obj
                @@sep_index = index
              elsif oct_date == date_obj
                @@oct_index = index
              elsif nov_date == date_obj
                @@nov_index = index
              elsif dec_date == date_obj
                @@dec_index = index
              elsif jan_next_year == date_obj
                @@jan_next_year_index = index
              end
            end 
            
            headers.each_index do |j|

              i = 0

              monthly_sum_jan = monthly_sum_feb = monthly_sum_mar = monthly_sum_apr = monthly_sum_may = monthly_sum_jun = monthly_sum_jul = monthly_sum_aug = monthly_sum_sep = monthly_sum_oct = monthly_sum_nov = monthly_sum_dec = annual_sum = 0
            
              # loop through values for each header
              all_values = monthly_values[headers[j]]

              # for each header store monthly sums of values
              all_values.each do |v|
                if i < @@feb_index
                  monthly_sum_jan += v.to_f
                  i += 1
                elsif @@feb_index <= i && i < @@mar_index
                  monthly_sum_feb += v.to_f
                  i += 1
                elsif @@mar_index <= i && i < @@apr_index
                  monthly_sum_mar += v.to_f
                  i += 1
                elsif @@apr_index <= i && i < @@may_index
                  monthly_sum_apr += v.to_f
                  i += 1
                elsif @@may_index <= i && i < @@jun_index
                  monthly_sum_may += v.to_f
                  i += 1
                elsif @@jun_index <= i && i < @@jul_index
                  monthly_sum_jun += v.to_f
                  i += 1
                elsif @@jul_index <= i && i < @@aug_index
                  monthly_sum_jul += v.to_f
                  i += 1
                elsif @@aug_index <= i && i < @@sep_index
                  monthly_sum_aug += v.to_f
                  i += 1
                elsif @@sep_index <= i && i < @@oct_index
                  monthly_sum_sep += v.to_f
                  i += 1
                elsif @@oct_index <= i && i < @@nov_index
                  monthly_sum_oct += v.to_f
                  i += 1
                elsif @@nov_index <= i && i < @@dec_index
                  monthly_sum_nov += v.to_f
                  i += 1
                elsif @@dec_index <= i && i < @@jan_next_year_index
                  monthly_sum_dec += v.to_f
                  i +=1
                # sum up all values for annual aggregate
                elsif i < size
                  annual_sum += v.to_f
                end
              end

              # store headers as key and monthly sums as values for each header
              monthly_totals[headers[j]] = [monthly_sum_jan, monthly_sum_feb, monthly_sum_mar, monthly_sum_apr, monthly_sum_may, monthly_sum_jun, monthly_sum_jul, monthly_sum_aug, monthly_sum_sep, monthly_sum_oct, monthly_sum_nov, monthly_sum_dec]
            
              annual_values[headers[j]] = annual_sum

              @scenario_results = {}
              @scenario_results["name"] = scenario_name
              @scenario_results["monthly_values"] = {}
              @scenario_results["annual_values"] = {}

            end
          end
          
          monthly_totals.each do |key, value|
            unless key == 'Datetime'
              @scenario_results["monthly_values"][key] = value
            end
          end

          annual_values.each do |key, value|
            unless key == 'Datetime'
              @scenario_results["annual_values"][key] = value
            end
          end 

          @all_scenario_results << @scenario_results

          end 

        # create json with required data stored in a variable
         results_path = File.join(root_dir, "/run/scenarioData.js")
         File.open(results_path, 'w') do |file|
          file << "var scenarioData = #{JSON.pretty_generate(@all_scenario_results)};"
        end 

        end
    
    end # ResultVisualization
  end # Scenario
end # URBANopt
