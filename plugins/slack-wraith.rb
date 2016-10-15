require "slack-ruby-client"

class SlackWraith
  attr_reader :token, :channel

  def initialize(token, channel)
    @token = token
    @channel = channel
  end

  def send_msg(results)
    return if @token.blank?

    puts "Sending to slack #{results}"

    gallery_url = results[:gallery_url]
    variation_url = results[:variation_url]

    client.chat_postMessage(
      channel: channel,
      text: "<!channel>: There are significant visual changes in #{variation_url}, please review #{gallery_url}",
      as_user: true
    )
  end

  def client
    if @client.nil?
      Slack.configure do |config|
        config.token = @token
      end

      @client = Slack::Web::Client.new
    end

    @client
  end
end
