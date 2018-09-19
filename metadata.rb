name 'git_checkout'
maintainer 'Xorima (Jason Field)'
maintainer_email '4923914+Xorima@users.noreply.github.com'
license 'Apache-2.0'
description 'Dynamically finds repositories and then clones them into the correct location'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.2'

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'freebsd'
supports 'mac_os_x'
supports 'omnios'
supports 'oracle'
supports 'redhat'
supports 'smartos'
supports 'scientific'
supports 'suse'
supports 'opensuse'
supports 'opensuseleap'
supports 'ubuntu'
supports 'windows'

source_url 'https://github.com/xorima/chef-cookbooks-git_checkout'
issues_url 'https://github.com/xorima/chef-cookbooks-git_checkout/issues'
chef_version '>= 13' if respond_to?(:chef_version)
