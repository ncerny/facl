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
property :user, [String, Hash, Array]
property :group, [String, Hash, Array]
property :mask, [String, Hash, Array]
property :other, [String, Hash, Array]
property :default, [String, Hash, Array]
property :recurse, [true, false], default: false

attr_reader :facl

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
  @facl ||= {}
  @facl[:user] = new_resource.user
  @facl[:group] = new_resource.group
  @facl[:other] = new_resource.other
  @facl[:mask] = new_resource.mask
  @facl[:default] = new_resource.default # ~FC001 ~FC039

  changes_required = diff(current_resource.facl, new_resource.facl)
  default = changes_required.delete(:default)
  changes_required.each do |inst, obj|
    obj.each do |_, value|
      setfacl(new_resource.path, inst, obj, value)
    end
  end
  default.each do |_, inst|
    inst.each do |obj, value|
      setfacl(new_resource.path, inst, obj, value, '-d')
    end
  end
end

action :modify do

end

action :remove do

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
  cmd.run_action
  cmd.error!
end
