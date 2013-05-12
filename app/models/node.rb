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
class Node
  require 'mcomaster/mcclient'
  
  #extend Mcomaster::McClient
  include Comparable

  attr_accessor :id, :agents, :facts, :checkin, :checkin_age

  def self.collectives
    collectives = $redis.keys("mcollective::collective::*")
    for ckey in collectives
      yield ckey.gsub(/^mcollective\:\:collective\:\:/, ""), ckey
    end    
  end
  
  def self.all
    now = Time.now.utc.to_i
    oldest = now - APP_CONFIG['discovery_ttl']

    a = Array.new
    
    collectives() { |cname,ckey|
      results = $redis.zrangebyscore(ckey, oldest, now)
      for node in results
        a.push(Node.new(:id => node, :collective => cname))
      end
    }
    
    return a.sort
  end

  def <=>(other)
    @id <=> other.id
  end

  def self.find(id)
    agents = $redis.smembers("mcollective::nodeagents::#{id}")
    
    if !agents.nil?
      return Node.new(:id => id, :agents => agents, :verbose => true)
    end
    return nil
  end
  
  def self.count()
    now = Time.now.utc.to_i
    oldest = now - APP_CONFIG['discovery_ttl']
    count = 0
    
    collectives() { |cname,ckey|
      count += $redis.zcount(ckey, oldest, now)
    }    
    
    return 
  end

  def initialize(args={})
    @id = args[:id]
    if args[:verbose]
      @agents = args[:agents]
      @facts = $redis.hgetall("mcollective::facts::#{id}")
      @checkin = $redis.get("mcollective::nodecheckin::#{id}")
      if !@checkin.nil?
        now = Time.now.utc.to_i
        @checkin_age = now - Integer(@checkin)
      end
    end
  end
end
