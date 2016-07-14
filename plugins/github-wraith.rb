require "octokit"
require "dotenv"

Dotenv.load

class GithubWraith
  def initialize(repo_name, pr_number, login, token, github_status)
    @repo_name = repo_name
    @pr_number = pr_number
    @login = login
    @token = token
    @pr = client.pull_request(@repo_name, @pr_number, options = {})
    @github_status = github_status
  end

  def send_msg(status, description, url)
    if @github_status
      puts "Setting GitHub PR Status"

      client.create_status(@pr['base']['repo']['full_name'], @pr['head']['sha'], status, options = {
        context: "Tremor",
        description: description,
        target_url: url
      })
    end
  end

  def writeConfig(fullName, variant_url)
    data = client.contents(fullName, :path => 'wraith.yaml', :ref => branch_name)
    decoded = Base64.decode64(data[:content])
    config = YAML.load decoded
    config["domains"].merge!("variant" => variant_url)

    File.open("wraith.yaml", 'w') { |file| file.write(YAML.dump(config)) }
  end


  private

  def client
    if @client.nil?
      @client = Octokit::Client.new \
        :login => @login,
        :password => @token
    end

    @client
  end

  def branch_name
    @pr.head.ref
  end
end
