require 'net/http'
require 'uri'
require 'json'

class ReportTremorStatus
  def initialize(token)
    @token = token
  end

  def caution!(details_url)
    uri = URI.parse("http://tremor.dev/check/#{@token}/caution")

    results = {
      details_url: details_url,
      message: nil
    }

    post_results(uri, results)
  end

  def all_clear!()
    uri = URI.parse("http://tremor.dev/check/#{@token}/all_clear")

    results = { }

    post_results(uri, results)
  end

  private

  def post_results(uri, results)
    header = { "Content-Type" => "text/json" }

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request["Content-Type"] = "application/json"
    request.body = { results: results }.to_json

    # Send the request
    http.request(request)
  end
end
