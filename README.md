# Git Checkout

Provides a set of resources to aid in the checkout of git repositories from hosted platforms

## Requirements

- git
- ssh keypair correctly set

### Chef

- Chef 13 +

## Resources

### bitbucket

Connects to BitBucket.org and find repositories, then calls the git resource to clone these to the specified disk, currently only supports checking out from the authenticated user

#### Token creation:

Go to Settings -> OAuth and create a new consumer

Set permissions to: Repositories -> Read

Add a callback URL, does not matter the given url, it requires one however. 

#### Actions

- `:create` - Creates the repositories on disk

#### Properties

- `username` - (Required) name attribute, the username for the account you wish to checkout from
- `access_key` - (Required) Access key for the OAuth Consumer
- `secret_key` - (Required) Secret key for the OAuth Consumer
- `path` - (Required) The root path to checkout into
- `owner` - (Required) The owner for the checked repository
- `group` - (Required) The group for the checked out repository
- `directory_seperator` - (Optional) This will create directories and split the path for the given string, eg: if given a repo of: chef-cookbooks-git_checkout and a directory_seperator of `-` then it will clone into `<path>/chef/cookbooks/git_checkout`
- `repo_filter` - (Optional) Regex filter for repositories you wish to clone. 


### github

Connects to Github.com and find repositories, then calls the git resource to clone these to the specified disk, supports private (authenticated) and public repositories for users and orgs

#### Token creation:

Go to https://github.com/settings/tokens and create a new Personal Access Token

Set permissions to: Repo (All) - The cookbook only required read access to private and public repositories, however this is not currently an option.

#### Actions

- `:create` - Creates the repositories on disk

#### Properties

- `username` - (Required) name attribute, the username for the account you wish to checkout from
- `org` - (Optional) If given we will clone from this org instead of from the supplied username
- `access_key` - (Optional) Personal Access Token for the OAuth Consumer, if not supplied this resource will only clone public repositories
- `path` - (Required) The root path to checkout into
- `owner` - (Required) The owner for the checked repository
- `group` - (Required) The group for the checked out repository
- `directory_seperator` - (Optional) This will create directories and split the path for the given string, eg: if given a repo of: chef-cookbooks-git_checkout and a directory_seperator of `-` then it will clone into `<path>/chef/cookbooks/git_checkout`
- repo_filter - (Optional) Regex filter for repositories you wish to clone. 
