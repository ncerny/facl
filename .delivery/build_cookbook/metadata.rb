name 'build_cookbook'
maintainer 'Nathan Cerny'
maintainer_email 'ncerny@gmail.com'
license 'apachev2'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'delivery-truck'
