require 'net/http'

current_matches_url = "http://worldcup.sfg.io/matches/today"
country_name = "country"
goals = "goals"
home_team = "home_team"
away_team = "away_team"
status = "status"
future_match_value = "future"
datetime_key = "datetime"

SCHEDULER.every '20s' do
  url = URI.parse(current_matches_url)
  request = Net::HTTP::Get.new(url.to_s)
  response = Net::HTTP.start(url.host, url.port) { |http|
    http.request(request)
  }

  score_list = []
  parsed_data = JSON.parse(response.body)

  parsed_data.each do |match|
    team_names_string = (match[home_team][country_name]).to_s + " vs " + (match[away_team][country_name]).to_s
    score_string = "(" + (match[home_team][goals]).to_s + " - " + (match[away_team][goals]).to_s + ")"
    if match["status"] == future_match_value
      score_list.push({'label': team_names_string, 'value': (Time.parse(match[datetime_key]).hour + 1).to_s + ":00"})
    else
      score_list.push({'label': team_names_string, 'value': score_string})
    end
  end

  send_event('matches', { items: score_list })
end
