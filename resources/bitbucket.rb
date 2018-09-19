# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

property :username, String, name_property: true
property :access_key, String, required: true, sensitive: true
property :secret_key, String, required: true, sensitive: true
property :path, String, required: true
property :owner, String, required: true
property :group, String, required: true
property :directory_seperator, String
property :repo_filter, default: /.*/


require 'net/http'
require 'json'

def get_repositories(uri, headers)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new uri.request_uri, headers
  repos = http.request(req)

  repositories = JSON.parse(repos.body)

  repos_filtered = []

  repositories['values'].each do |repo|
    repo['links']['clone'].each do |clone|
      # we will only clone ssh so we do not deal with auth details
      if clone['name'] == 'ssh'
        repos_filtered.push('href' => clone['href'], 'name' => repo['name'])
      end
    end
  end
  res = { 'repos' => repos_filtered, 'next' => repositories['next'] }
  res
end

def get_all_repositories(uri, headers)
  res = []
  repos = get_repositories(uri, headers)
  res += repos['repos']

  until repos['next'].nil?
    uri = URI(repos['next'])
    repos = get_repositories(uri, headers)
    res += repos['repos']
  end

  res
end

def get_auth_token(uri, access_key, secret_key)
  body = { 'grant_type' => 'client_credentials' }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new uri.request_uri
  req.basic_auth(access_key, secret_key)
  req.set_form_data(body)
  auth = http.request(req)

  auth_body = JSON.parse(auth.body)
  auth_body['access_token']
end

action :create do
  auth_uri = URI('https://bitbucket.org/site/oauth2/access_token')
  repo_uri = URI("https://bitbucket.org/api/2.0/repositories/#{new_resource.username}")

  auth_token = get_auth_token(auth_uri, new_resource.access_key, new_resource.secret_key)

  headers = { 'Authorization' => "Bearer #{auth_token}" }

  repos_filtered = get_all_repositories(repo_uri, headers)
  repos_filtered.each do |repo|
    clone = repo['name'].match(new_resource.repo_filter)
    unless clone.nil?
      if new_resource.directory_seperator.nil?
        path = "#{new_resource.path}/#{repo['name']}"
      else
        path = "#{new_resource.path}/#{repo['name'].split(new_resource.directory_seperator).join('/')}"
        directory path do
          recursive true
          owner new_resource.owner
          group  new_resource.group
        end
      end
      git path do
        repository repo['href'].to_s
      end
    end
  end
end
