# facl

Cookbook used to setup POSIX filesystem ACL's on Linux.

## Examples

### Individual file
```
include_recipe 'facl'

facl '/tmp/facl_test' do
  user :'' => 'rw',
       test_user: 'rwx'
  group :'' => 'rw'
  mask :'' => 'rwx'
  other :'' => 'r'
end
```

### Directory
```
include_recipe 'facl'

facl '/tmp/facl_test_dir' do
  user :'' => 'rw',
       test_user: 'rwx'
  group :'' => 'rw'
  mask :'' => 'rwx'
  other :'' => 'r'
end
```

### Directory, recursive
```
include_recipe 'facl'

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
```
