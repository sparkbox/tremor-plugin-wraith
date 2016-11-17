require "octokit"
require "dotenv"

Dotenv.load

class GithubWraith
  def initialize(repo_name, login, token, branch)
    @repo_name = repo_name
    @login = login
    @token = token
    @branch = branch
  end

  def writeConfig(fullName, variant_url)
    data = client.contents(fullName, path: 'wraith.yaml', ref: branch_name)
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
    @branch || "master"
  end
end
