# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

property :username, String, name_property: true
property :org, String
property :access_key, String, required: false, sensitive: true
property :path, String, required: true
property :owner, String, required: true
property :group, String, required: true
property :directory_seperator, String
property :repo_filter, default: /.*/

require 'net/http'
require 'json'

def get_repositories(uri, username, access_key)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new uri.request_uri
  if access_key.nil?
    Chef::Log.info('No access key given, cloning public repos only')
  else
    req.basic_auth(username, access_key)
  end
  repos = http.request(req)
  if repos.code != '200'
    Chef::Log.error('Unable to access github correctly.')
    raise "Invalid response code: #{repos.code}"
  end
  repositories = JSON.parse(repos.body)

  repos_filtered = []

  repositories.each do |repo|
    repos_filtered.push('href' => repo['ssh_url'], 'name' => repo['name'])
  end
  Chef::Log.info(repos_filtered)
  repos_filtered
end

action :create do
  # Check if cloning an org or a user
  if new_resource.org.nil?
    repo_uri = URI("https://api.github.com/users/#{new_resource.username}/repos")
  else
    repo_uri = URI("https://api.github.com/orgs/#{new_resource.org}/repos")
  end
  Chef::Log.info(repo_uri)
  repos_filtered = get_repositories(repo_uri, new_resource.username, new_resource.access_key)
  repos_filtered.each do |repo|
    clone = repo['name'].match(new_resource.repo_filter)
    unless clone.nil?
      if new_resource.directory_seperator.nil?
        path = "#{new_resource.path}/#{repo['name']}"
      else
        path = "#{new_resource.path}/#{repo['name'].split(new_resource.directory_seperator).join('/')}"
        directory path do
          recursive true
          owener new_resource.owner
          group  new_resource.group
        end
      end
      git path do
        repository repo['href'].to_s
      end
    end
  end
end
