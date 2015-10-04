require 'json'
require 'csv'
require './lib/json_response_checker.rb'

STORAGE_DIR = "./storage/out"

Dir.foreach(STORAGE_DIR) {|storage_dir|
  json_dir = "#{STORAGE_DIR}/#{storage_dir}/json/results"
  check_dir = "#{STORAGE_DIR}/#{storage_dir}/check"
  if Dir.exist?(json_dir)
    if !Dir.exist?(check_dir)
      records = []

      records << JsonResponseChecker.headers()
      Dir.mkdir(check_dir)
      Dir.foreach(json_dir) {|file_name|
        if file_name[-5, 5] == ".json"
          json_str = File.read("#{json_dir}/#{file_name}")
          record = JsonResponseChecker.execute(json_str)
          if record
            records << record
          end
        end
      }

      CSV.open("#{check_dir}/json_checker_#{DateTime.now.strftime("%Y%m%d_%H%M%S")}.csv", "w", :encoding => "SJIS") {|line|
        records.each {|record|
          line << record
        }
      }

    end
  end
}

