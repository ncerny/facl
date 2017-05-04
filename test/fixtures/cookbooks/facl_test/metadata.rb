name 'facl_test'
maintainer 'Nathan Cerny'
maintainer_email 'ncerny@gmail.com'
license 'Apache-2.0'
description 'Installs/Configures facl'
long_description 'Installs/Configures facl'

version '0.1.0'

chef_version '>= 12.1' if respond_to?(:chef_version)

issues_url 'https://github.com/cerny-cc/facl/issues' if respond_to?(:issues_url)
source_url 'https://github.com/cerny-cc/facl' if respond_to?(:source_url)

supports 'redhat'
supports 'centos'

depends 'facl'
