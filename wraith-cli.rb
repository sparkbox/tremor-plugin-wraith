require "thor"
require_relative "./plugins/github-wraith"
require_relative "./report_tremor_status"
require_relative "./uploader"

class Wraithify < Thor
  desc "check", "check site with wraith"
  options :tremor_token => :string,
    :repo_name => :string,
    :branch => :string,
    :variant_url => :string,
    :login => :string,
    :oauth_token => :string,
    :s3_key_id => :string,
    :s3_secret_key => :string

  def check
    print "Starting Wraith..."
    gh = GithubWraith.new(options[:repo_name], options[:login], options[:oauth_token], options[:branch])
    puts "Done"

    gh.writeConfig(options[:repo_name], options[:variant_url])

    # Run Wraith!!!
    wraith_result = system "bundle exec wraith capture ./wraith.yaml"

    print "Uploading comparison gallery..."

    # Upload the comparison gallery
    gallery_url = Uploader
      .new(options[:s3_key_id], options[:s3_secret_key])
      .upload
    puts "Done"

    print "Reporting status to tremor..."
    report_tremor_status = ReportTremorStatus.new(options[:tremor_token])

    if wraith_result
      report_tremor_status.all_clear!(gallery_url)
    else
      report_tremor_status.caution!(gallery_url)
    end
    puts "Done"
  end
end

Wraithify.start(ARGV)
