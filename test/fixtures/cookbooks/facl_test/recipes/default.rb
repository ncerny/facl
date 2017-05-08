include_recipe 'facl'

ohai 'reload' do
  action :nothing
end

user 'test_user' do
  notifies :reload, 'ohai[reload]', :immediately
end

file '/tmp/facl_test'

facl '/tmp/facl_test' do
  user :'' => 'rw',
       test_user: 'rwx'
  group :'' => 'rw'
  mask :'' => 'rwx'
  other :'' => 'r'
end

directory '/tmp/facl_test_dir'

facl '/tmp/facl_test_dir' do
  user :'' => 'rw',
       test_user: 'rwx'
  group :'' => 'rw'
  mask :'' => 'rwx'
  other :'' => 'r'
  # default 'user:test_user:rw'
end

['/tmp/test','/tmp/test/recursion','/tmp/test/recursion/for','/tmp/test/recursion/for/module'].each do |k|
  directory k
end

facl '/tmp/test' do
  user :'' => 'rw',
       test_user: 'rwx'
  group :'' => 'rw'
  mask :'' => 'rwx'
  other :'' => 'r'
  recurse true
end
