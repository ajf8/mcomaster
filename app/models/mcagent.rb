# Copyright 2013 ajf http://github.com/ajf8
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
#
class Mcagent
  require 'mcomaster/mcclient'
  
  include Mcomaster::McClient
  extend Mcomaster::McClient
  
  include Comparable
  
  attr_accessor :id, :actions, :ddl, :meta
  
  def self.all
    agents = Array.new
    results = $redis.keys("mcollective::agent::*")
    for e in results
      Rails.logger.info("found agent #{e}")
      e.gsub!(/^mcollective\:\:agent\:\:/, "")
      begin
        agents.push(Mcagent.new(:id => e))
      rescue => ex
        Rails.logger.error(ex.message+"\n"+ex.backtrace.join("\n"))
      end
    end
    return agents.sort
  end

  def <=>(other)
    @id <=> other.id
  end
  
  def self.find(id)
    if $redis.exists("mcollective::agent::#{id}")
      return Mcagent.new(:id => id, :verbose => true)
    end
    nil
  end
  
  def initialize(args)
    @id = args[:id]
    ddl = get_ddl(@id)
    if args[:verbose] == true
      @ddl = ddl
    else
      @actions = Hash.new
      ddl[:actions].each_pair{ |k,v|
        @actions[k] = v[:description]
      }
    end
  end
end
