require 'json'
require 'csv'
require './lib/json_response_converter.rb'
STORAGE_DIR = "./storage/out"

records = []
Dir.foreach(STORAGE_DIR) {|storage_dir|
  json_dir = "#{STORAGE_DIR}/#{storage_dir}/json/results"
  csv_dir = "#{STORAGE_DIR}/#{storage_dir}/csv"
  if Dir.exist?(json_dir)
    if !Dir.exist?(csv_dir)
      Dir.mkdir(csv_dir)
      records << JsonResponseConverter.headers()
      Dir.foreach(json_dir) {|file_name|
        if file_name[-5, 5] == ".json"
          json_str = File.read("#{json_dir}/#{file_name}")
          record = JsonResponseConverter.details(json_str)
          if record
            records << record
          end
        end
      }

      CSV.open("#{csv_dir}/ca_scores_#{DateTime.now.strftime("%Y%m%d_%H%M%S")}.csv", "w", :encoding => "SJIS") {|line|
        records.each {|record|
          line << record
        }
      }

    end
  end
}

