require 'json'

CATEGORIES = {
 '肥満' => {
   'nb_plot_values' => 2,
   'jlac10_codes' => [
     '9N011000000000001',
     '9N016160100000001'
   ]
 },
 '高血圧' => {
   'nb_plot_values' => 2,
   'jlac10_codes' => [
     '9A751000000000001',
     '9A752000000000001',
     '9A755000000000001',
     '9A761000000000001',
     '9A762000000000001',
     '9A765000000000001'
   ]
 },
 '高血糖' => {
   'nb_plot_values' => 2,
   'jlac10_codes' => [
     '3D010000001926101',
     '3D045000001906202',
     '3D046000001906202'
   ]
 },
 '脂質異常' => {
   'nb_plot_values' => 3,
   'jlac10_codes' => [
     '3F015000002327101',
     '3F070000002327101',
     '3F077000002327101',
   ]
 },
 '肝機能' => {
   'nb_plot_values' => 3,
   'jlac10_codes' => [
     '3B035000002327201',
     '3B045000002327201',
     '3B090000002327101'
   ]
 },
 '貧血' => {
   'nb_plot_values' => 3,
   'jlac10_codes' => [
     '2A020000001930101',
     '2A030000001930101',
     '2A040000001930102'
   ]
 },
 '腎機能' => {
   'nb_plot_values' => 1,
   'jlac10_codes' => [
     '1A010000000190111'
   ]
 },
 '糖代謝' => {
   'nb_plot_values' => 1,
   'jlac10_codes' => [
     '1A020000000190111'
   ]
 },
}

LIFE_CHECKS = {
  'eat' => {
    'details' => ['eat_speed', 'before_sleep', 'after_dinner', 'breakfast']
  },
  'motion' => {
    'details' => ['motion_30min', 'motion_walk', 'walk_speed']
  },
  'drink' => {
    'details' => ['frequency_drink', 'amount_drink']
  },
  'smoking' => {
    'details' => ['habit_smoking']
  },
  'sleep' => {
    'details' => ['sleep_status']
  },
}

class JsonResponseChecker
  def self.execute(json_str)
    res = []
    hash = JSON.parse(json_str)

    if hash['code'] == 200
      res = self.check_data(hash['data'])
      return res
    else
      return nil
    end
  end

  def self.headers()
    res = []
    res << 'user_key'
    res << 'nb_exams'
    CATEGORIES.each {|(name, values)|
      res << 'category_name'
      res << 'match_nb_plot_values'
      res << 'jlac10codes_proper'
      res << "#{name}weather_msg"
      res << "#{name}weather_hantei"
      res << "#{name}hantei_msg"
      res << "#{name}hantei"
      res << "#{name}proper_hantei"
      values['jlac10_codes'].each {|jlac10_cd|
        res << "nb_values_in_#{jlac10_cd}"
        res << "not_exceed_nb_exams_in_#{jlac10_cd}"
      }
    }

    LIFE_CHECKS.each {|(name, values)|
      res << name
      values['details'].each {|detail|
        res << detail
      }
    }

    return res
  end

  private
  def self.check_data(data)
    res = []

    res << data['user_key']
    nb_exams = data['score']['score_plot'].count
    res << nb_exams
    CATEGORIES.each {|(name, values)|
      category = data['check']['categories'].detect {|hash|
        hash['risk_nm'] == name
      }

      res << name
      match_nb_plot_values = values['nb_plot_values'].to_i >= category['plot_values'].count
      res << match_nb_plot_values
      jlac10codes_proper = true

      category['plot_values'].each {|plot_value|
        if !values['jlac10_codes'].include?(plot_value['jlac10_cd'])
          jlac10codes_proper = false
        end
      }

      res << jlac10codes_proper

      res << "#{category['weather_msg']}"
      res << "#{category['weather_hantei']}"
      res << "#{category['msg']}"
      res << "#{category['hantei']}"
      proper_hantei = !(category['weather_hantei'] == 0 || category['hantei'] == 0)
      proper_hantei = category['weather_hantei'] == 0 && category['hantei'] == 0 ? true : proper_hantei
      res << proper_hantei

      values['jlac10_codes'].each {|jlac10_cd|
        plot_value = category['plot_values'].detect {|hash|
          hash['jlac10_cd'] == jlac10_cd
        }

        nb_results = 0
        if plot_value
          nb_results = plot_value['values'].count
        end
        res << nb_results
        not_exceed_nb_exams = nb_results <= nb_exams
        res << not_exceed_nb_exams
      }
    }

    LIFE_CHECKS.each {|(name, values)|
      has_this_name = data['life_check']['check'].include?(name)
      res << has_this_name

      values['details'].each {|detail|
        if has_this_name
          has_this_detail = data['life_check']['check'][name].include?(detail)
          res << has_this_detail
        else
          res << "no #{name}"
        end
      }
    }

    return res
  end
end
