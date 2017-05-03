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
property :user, [String, Hash, Array]
property :group, [String, Hash, Array]
property :mask, [String, Hash, Array]
property :other, [String, Hash, Array]
property :default, [String, Hash, Array]

load_current_value do
  facl = getfacl path || current_value_does_not_exist!
  user facl[:user]
  group facl[:group]
  mask facl[:mask]
  other facl[:other]
  default facl[:default]
end

action :set do

end

action :modify do

end

action :remove do

end

def getfacl(path)
  cmd = Mixlib::ShellOut.new("getfacl #{path}")
  cmd.run_command
  cmd.error!
  facl_to_hash(cmd.stdout)
end

def set(hash)

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
