require 'httpclient'
require 'json'

FILE_DIR = "storage/in"
HOST_NAME = "http://192.168.33.80"
API_NAME = "/api/v1/check_and_action/scores"

# start to get files
file_names = []
limit = 10
count = 0
Dir.foreach(FILE_DIR) { |file_name|
  if file_name[-5, 5] == ".json"
    file_names << file_name
    count += 1
  end
  # break if count == limit
}
# end to get files

dir_name = DateTime.now.strftime('%Y%m%d_%H%M%S')
result_dir = "./storage/out/#{dir_name}"
json_dir = "./storage/out/#{dir_name}/json"
results_json_dir = "./storage/out/#{dir_name}/json/results"
errors_json_dir = "./storage/out/#{dir_name}/json/errors"
Dir.mkdir(result_dir)
Dir.mkdir(json_dir)
Dir.mkdir(results_json_dir)
Dir.mkdir(errors_json_dir)

client = HTTPClient.new
file_names.each {|file_name|
  file_path = "#{FILE_DIR}/#{file_name}"

  File.open(file_path) {|io|
    post_data = {'file' => io}
    
    begin  
      res = client.post_content("#{HOST_NAME}#{API_NAME}", post_data, {
        'content-type' => 'multipart/form-data; boundary=boundary'
      })
      res_parsed = JSON.parse(res)
      if res_parsed['code'] == 200
        File.open("#{results_json_dir}/result_json_#{file_name}", "w") {|line|
          line << res
        }
      else
        File.open("#{errors_json_dir}/error_json_#{file_name}", "w") {|line|
          line << res
        }
      end
    rescue
      res = false
      File.open("#{errors_json_dir}/error_#{file_name}", "w") {|line|
        line << 'unknown error'
      }
    end
  }
}
