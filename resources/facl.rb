#
# Cookbook:: facl
# Resource:: facle
#
# Copyright:: 2017, Nathan Cerny
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource_name 'facl'

property :path, String, name_property: true
# property :rules, String
property :user, [String, Hash, Array], default: {}
property :group, [String, Hash, Array], default: {}
property :mask, [String, Hash, Array], default: {}
property :other, [String, Hash, Array], default: {}
property :default, [String, Hash, Array], default: {}
property :recurse, [true, false], default: false

attr_accessor :facl

# facl '/share' do
#   user tommy: 'rwx',
#        freddie: 'rw',
#   user 'tommy:rwx'
#   rules 'user:tommy:rwx'

load_current_value do
  cmd = Mixlib::ShellOut.new("getfacl #{path}")
  cmd.run_command
  current_value_does_not_exist! if cmd.error!
  @facl = facl_to_hash(cmd.stdout)

  # rules cmd.stdout
  user facl[:user]
  group facl[:group]
  mask facl[:mask]
  other facl[:other]
  default facl[:default] # ~FC001 ~FC039
end

action :set do
  raise "Cannot set ACL because File #{new_resource.path} does not exist!" unless ::File.exist?(new_resource.path)

  new_resource.facl = {
    user: new_resource.user,
    group: new_resource.group,
    other: new_resource.other,
    mask: new_resource.mask,
    default: new_resource.default,
  }

  recurse = new_resource.recurse

  p 'Current Resource:'
  p current_resource.facl
  p 'New Resource:'
  p new_resource.facl

  changes_required = diff(current_resource.facl, new_resource.facl)
  p "Changes Required: #{changes_required}"
  default = changes_required.delete(:default)
  changes_required.each do |inst, obj|
    obj.each do |key, value|
      if recurse and ::File.directory?(new_resource.path)
        setfacl(new_resource.path, inst, key, value, flags='-R')
      else
        converge_by("Setting ACL (#{inst}:#{key}:#{value}) on #{new_resource.path}") do
          setfacl(new_resource.path, inst, key, value)
        end
      end
    end
  end if changes_required
  default.each do |inst, obj|
    obj.each do |key, value|
      raise 'Default ACL only valid on Directories!' unless ::File.directory?(new_resource.path)
      converge_by("Setting Default Directory ACL (#{inst}:#{key}:#{value}) on #{new_resource.path}") do
        setfacl(new_resource.path, inst, key, value, '-d')
      end
    end
  end if default
end

def facl_to_hash(string)
  facl = { default: {}, user: {}, group: {}, mask: {}, other: {} }
  string.each_line do |line|
    next unless line =~ /^(default|user|group|mask|other):/
    l = line.split(':')
    next if l.length < 3
    facl[l[0].to_sym] ||= {}
    if l[0].eql?('default')
      facl[l[0].to_sym][l[1].to_sym] ||= {}
      facl[l[0].to_sym][l[1].to_sym][l[2].to_sym] = l[3].strip
    else
      facl[l[0].to_sym][l[1].to_sym] = l[2].strip
    end
  end
  facl
end

def diff(cur_r, new_r)
  diff = {}
  (cur_r.keys - new_r.keys).each do |k|
    diff[k] = :remove
  end

  (new_r.keys - cur_r.keys).each do |k|
    diff[k] = new_r[k]
  end

  (new_r.keys & cur_r.keys).each do |k|
    next if cur_r[k].eql?(new_r[k])
    diff[k] = (cur_r[k].is_a?(Hash) ? diff(cur_r[k], new_r[k]) : new_r[k])
  end

  diff
end

def setfacl(path, inst, obj, value, flags = '')
  op = (value.eql?(:remove) ? '-x' : '-m')
  cmd = Mixlib::ShellOut.new("setfacl #{flags} #{op} #{inst}:#{obj}:#{value} #{path}")
  cmd.run_command
  cmd.error!
end
