require "thor"
require_relative "./plugins/slack-wraith"
require_relative "./plugins/github-wraith"
require_relative "./uploader"

class Wraithify < Thor
  desc "check", "check site with wraith"
  options :repo_name => :string,
          :pr_number => :string,
          :slack_channel => :string,
          :slack_token => :slack_token,
          :variant_url => :string,
          :login => :string,
          :oauth_token => :string,
          :s3_key_id => :string,
          :s3_secret_key => :string,
          :github_status => :boolean

  def check
    puts "Starting Wraith..."
    gh = GithubWraith.new(options[:repo_name], options[:pr_number], options[:login], options[:oauth_token], options[:github_status])
    slack = SlackWraith.new(options[:slack_token], options[:slack_channel])

    # Set the state of the P
    gh.send_msg("pending", "Checking for visual differences", options[:variant_url])

    gh.writeConfig(options[:repo_name], options[:variant_url])

    wraith_result = system "bundle exec wraith capture ./wraith.yaml"

    if wraith_result
      # Set the state of the PR
      gh.send_msg("success", "No significant visual differences", options[:variant_url])

      # Notify Slack
      slack.send_msg("No significant visual differences found in #{options[:variant_url]}")
    else
      results = {}

      # Upload the comparison gallery
      results[:gallery_url] = Uploader
        .new(options[:s3_key_id], options[:s3_secret_key])
        .upload

      # Hang on to the variation url (vs the baseline)
      results[:variation_url] = "#{options[:variant_url]}"

      # Notify Slack
      slack.send_msg(results)

      # Set the state of the PR
      gh.send_msg("failure", "Significant visual differences found!", options[:variant_url])
    end
  end
end

Wraithify.start(ARGV)
