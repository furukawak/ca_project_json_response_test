require 'httpclient'
require 'json'

FILE_ROOT = "storage"
HOST_NAME = "http://192.168.33.80"
API_NAME = "/api/v1/check_and_action/scores"

input_file_dirs = []
indexes = []

count = 0
p "please, choose dir below."
Dir.foreach(FILE_ROOT) {|dir_nm|
  if dir_nm[0, 2] == 'in'
    p "#{count}: #{dir_nm}"
    input_file_dirs << dir_nm
    indexes << count.to_s
    count += 1
  end
}

dirs_index = false
while !indexes.include?(dirs_index)
  dirs_index = gets().chomp
  if !indexes.include?(dirs_index)
    p 'opps! please, choose dir above.'
  end
end

child_dir_nm = input_file_dirs[dirs_index.to_i]
# start to get files
file_names = []

needs_limit_ans = ''
while !['y', 'Y', 'N', 'n'].include?(needs_limit_ans)
  p 'need limit ? [y/n]'
  needs_limit_ans = gets.chomp
end

if ['y', 'Y'].include?(needs_limit_ans)
  needs_limit = true
else
  needs_limit = false
end

limit = 10

count = 0
Dir.foreach("#{FILE_ROOT}/#{child_dir_nm}") { |file_name|
  if file_name[-5, 5] == ".json"
    file_names << file_name
    count += 1
  end

  if needs_limit
    break if count == limit
  end
}
# end to get files

dir_name = DateTime.now.strftime('%Y%m%d_%H%M%S')
result_dir = "./storage/out/from_#{child_dir_nm}_#{dir_name}"
json_dir = "./storage/out/from_#{child_dir_nm}_#{dir_name}/json"
results_json_dir = "./storage/out/from_#{child_dir_nm}_#{dir_name}/json/results"
errors_json_dir = "./storage/out/from_#{child_dir_nm}_#{dir_name}/json/errors"
Dir.mkdir(result_dir)
Dir.mkdir(json_dir)
Dir.mkdir(results_json_dir)
Dir.mkdir(errors_json_dir)

p "started at #{DateTime.now.strftime('%Y/%m/%d %H:%M:%S')}. num of files is #{file_names.count}"
client = HTTPClient.new
file_names.each {|file_name|
  file_path = "#{FILE_ROOT}/#{child_dir_nm}/#{file_name}"


  text_json = File.read(file_path)
  begin  
    res = client.post_content("#{HOST_NAME}#{API_NAME}", text_json, 'Content-Type' => 'application/json')
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
p "finished at #{DateTime.now.strftime('%Y/%m/%d %H:%M:%S')}"
