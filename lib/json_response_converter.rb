require 'json'

class JsonResponseConverter
  def self.details(json_str)
    hash = JSON.parse(json_str)

    if hash['code'] == 200
      res = self.details_standard(hash)
      return res
    else
      return nil
    end
  end

  def self.headers()
    res = []

    res << 'user_key'
    res << 'imgUrl'
    0.upto(11) {|count|
      res << "area_no[#{count}]"
      res << "max[#{count}]"
      res << "min[#{count}]"
      res << "std[#{count}]"
    }

    0.upto(7) {|count|
      res << "age[#{count}]"
      res << "score[#{count}]"
    }
    
    res << "past_score"
    res << "past_hantei"
    res << "score"
    res << "hantei"
    res << "flg"
    res << "average_cnt"

    0.upto(7) {|ctg_count|
      res << "sort_no[#{ctg_count}]"
      res << "medication[#{ctg_count}]"
      res << "risk_nm[#{ctg_count}]"
      res << "hantei[#{ctg_count}]"
      res << "hantei_ja[#{ctg_count}]"
      res << "msg[#{ctg_count}]"
      res << "weather_hantei[#{ctg_count}]"
      res << "weather_msg[#{ctg_count}]"
      res << "category_score[#{ctg_count}]" # should remove
      res << "avg_category_score[#{ctg_count}]" # should remove
      0.upto(2) {|plt_val_count|
        res << "jlac10_cd[#{ctg_count}#{plt_val_count}]"
        res << "name[#{ctg_count}#{plt_val_count}]"
        res << "std[#{ctg_count}#{plt_val_count}]"
        res << "unit[#{ctg_count}#{plt_val_count}]"
        0.upto(7) {|val_count|
          res << "value[#{ctg_count}#{plt_val_count}#{val_count}]"
          res << "age[#{ctg_count}#{plt_val_count}#{val_count}]"
          res << "hantei[#{ctg_count}#{plt_val_count}#{val_count}]"
          res << "score[#{ctg_count}#{plt_val_count}#{val_count}]" # should remove
        }
      }
    }

    res << 'average_cnt'
    ['eat', 'motion', 'drink', 'smoke'].each {|type|
      res << "habit_#{type}"
      res << "habit_#{type}_msg"
    }

    [
      'eat_speed', 'before_sleep', 'after_dinner', 'breakfast',
      'motion_30min', 'motion_walk', 'walk_speed',
      'frequency_drink', 'amount_drink',
      'habit_smoking',
      'sleep_status'
    ].each {|type|
      res << "#{type}_flg"
      res << "#{type}_value"
    }

    res << 'count'
    res << 'msg'
    res << 'risk'
    res << 'habit'

    0.upto(2) {|count|
      res << "sort_no[#{count}]"
      res << "flg[#{count}]"
      res << "title[#{count}]"
      res << "advice1[#{count}]"
      res << "advice2[#{count}]"
      res << "advice3[#{count}]"
    }
    return res
  end

  private
  def self.details_standard(hash)
    res = []
    res << hash['data']['user_key']
    res << hash['data']['summary']['imgUrl']

    area_plots = hash['data']['score']['area_plot'].sort {|area_plot1, area_plot2|
      area_plot1['area_no'] <=> area_plot2['area_no']
    }

    0.upto(11) {|count|
      res << area_plots[count]['area_no']
      res << area_plots[count]['max']
      res << area_plots[count]['min']
      res << area_plots[count]['std']
    }

    score_plots = hash['data']['score']['score_plot'].sort {|score_plot1, score_plot2|
      score_plot2['age'] <=> score_plot1['age']
    }

    0.upto(7) {|count|
      if score_plots[count]
        res << score_plots[count]['age']
        res << score_plots[count]['score']
      else
        res << nil
        res << nil
      end
    }

    res << hash['data']['score']['compare_plot']['past_score']
    res << hash['data']['score']['compare_plot']['past_hantei']
    res << hash['data']['score']['compare_plot']['score']
    res << hash['data']['score']['compare_plot']['hantei']
    res << hash['data']['score']['compare_plot']['flg']
    res << hash['data']['check']['average_cnt']

    categories = hash['data']['check']['categories'].sort {|category1, category2|
      category1['sort_no'] <=> category2['sort_no']
    }
    0.upto(7) {|ctg_count|
      if categories[ctg_count]
        res << categories[ctg_count]['sort_no']
        res << categories[ctg_count]['medication']
        res << categories[ctg_count]['risk_nm']
        res << categories[ctg_count]['hantei']
        res << categories[ctg_count]['hantei_ja']
        res << categories[ctg_count]['msg']
        res << categories[ctg_count]['weather_hantei']
        res << categories[ctg_count]['weather_msg']
        res << categories[ctg_count]['category_score'] # should remove
        res << categories[ctg_count]['avg_category_score'] # should remove

        plot_values = categories[ctg_count]['plot_values'].sort {|plot_value1, plot_value2|
          plot_value1['jlac10_cd'] <=> plot_value2['jlac10_cd']
        }

        0.upto(2) {|plt_val_count|
          if plot_values[plt_val_count]
            res << plot_values[plt_val_count]['jlac10_cd']
            res << plot_values[plt_val_count]['name']
            res << plot_values[plt_val_count]['std']
            res << plot_values[plt_val_count]['unit']

            values = plot_values[plt_val_count]['values'].sort {|value1, value2|
              value2['age'] <=> value1['age']
            }

            0.upto(7) {|val_count|
              if values[val_count]
                res << values[val_count]['value']
                res << values[val_count]['age']
                res << values[val_count]['hantei']
                res << values[val_count]['score'] # should remove
              else
                # values
                res << nil
                res << nil
                res << nil
                res << nil # should remove
              end
            }
          else
            # plot values
            res << nil
            res << nil
            res << nil
            res << nil
            0.upto(7) {|val_count|
              # values
              res << nil
              res << nil
              res << nil
              res << nil # should remove
            }
          end
        }
      else
        # categories
        res << nil
        res << nil
        res << nil
        res << nil
        res << nil
        res << nil
        res << nil
        res << nil
        res << nil # should remove
        res << nil # should remove
        0.upto(2) {|plt_val_count|
          # plot values
          res << nil
          res << nil
          res << nil
          res << nil
          0.upto(7) {|val_count|
            # values
            res << nil
            res << nil
            res << nil
            res << nil # should remove
          }
        }
      end
    }


    res << hash['data']['life_check']['chart']['average_cnt']
    ['eat', 'motion', 'drink', 'smoke'].each {|type|
      res << hash['data']['life_check']["habit_#{type}"]
      res << hash['data']['life_check']["habit_#{type}_msg"]
    }

    {
      'eat' => ['eat_speed', 'before_sleep', 'after_dinner', 'breakfast'],
      'motion' => ['motion_30min', 'motion_walk', 'walk_speed'],
      'drink' => ['frequency_drink', 'amount_drink'],
      'smoking' => ['habit_smoking'],
      'sleep' => ['sleep_status']
    }.each {|(key, details)|
      details.each {|detail|
        if hash['data']['life_check']['check'][key]
          if hash['data']['life_check']['check'][key][detail]
            res << hash['data']['life_check']['check'][key][detail]['flg']
            res << hash['data']['life_check']['check'][key][detail]['value']
          else
            res << nil
            res << nil
          end
        else
          res << nil
          res << nil
        end
      }
    }

    res << hash['data']['life_check']['check']['count']
    res << hash['data']['life_check']['check']['msg']
    res << hash['data']['suggest']['risk']
    res << hash['data']['suggest']['habit']

    advices = hash['data']['suggest']['advice'].sort {|advice1, advice2|
      advice1['sort_no'] <=> advice2['sort_no']
    }

    0.upto(2) {|count|
      if advices[count]
        res << advices[count]['sort_no']
        res << advices[count]['flg']
        res << advices[count]['title']
        res << advices[count]['advice1']
        res << advices[count]['advice2']
        res << advices[count]['advice3']
      else
        res << nil
        res << nil
        res << nil
        res << nil
        res << nil
        res << nil
      end
    }

    return res
  end

  def self.details_error(hash)
  end
end
