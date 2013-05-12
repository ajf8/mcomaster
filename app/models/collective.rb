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
class Collective
  require 'mcomaster/mcclient'
  
  include Mcomaster::McClient
  extend Mcomaster::McClient
  
  include Comparable
  
  attr_accessor :id, :members
  
  def self.all
    results = $redis.keys("mcollective::collective::*")
    collectives = Array.new
    for e in results
      e.gsub!(/^mcollective\:\:collective\:\:/, "")
      collectives.push(Collective.new(:id => e))
    end    
    return collectives.sort
  end

  def <=>(other)
    @id <=> other.id
  end
  
  def self.find(id)
    ckey = "mcollective::collective::#{id}"
    if $redis.exists(ckey)
      now = Time.now.utc.to_i
      oldest = now - APP_CONFIG['discovery_ttl']
      members = $redis.zrangebyscore(ckey, oldest, now)
      return Collective.new(:id => id, :members => members)
    end
    nil
  end
  
  def initialize(args)
    @id = args[:id]
    if !args[:members].nil?
      @members = args[:members]
    end
  end
end
