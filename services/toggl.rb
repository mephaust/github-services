class Service::Toggl < Service
  def receive_push
    http.url_prefix = "https://www.toggl.com/api/v5"
    http.basic_auth data['api_token'], 'api_token'
    http.headers['Content-Type'] = 'application/json'

    payload["commits"].each do |commit|
      duration = (commit["message"].split(/\s/).find { |item| /t:/ =~ item } || "")[2,100]
      next unless duration

      # Toggl wants it in seconds.  Commits should be in seconds
      duration = duration.to_i * 60

      http_post "tasks.json", {
        :task => {
          :duration => duration.to_i,
          :description => commit["message"].strip,
          :project => data["project"],
          :start => (Time.now - duration.to_i).iso8601,
          :billable => true,
          :created_with => "github",
          :stop => Time.now.iso8601
        }
      }.to_json

    end
  end
end
