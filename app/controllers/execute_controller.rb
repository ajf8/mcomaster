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
class ExecuteController < ApplicationController
  require 'mcomaster/mcclient'
  require 'mcomaster/restmqclient'
  
  include Mcomaster::McClient
  include Mcomaster::RestMQ
  
  before_filter :authenticate_user!
  
  def execute
    agent = params[:agent]
    action = params[:mcaction]
    mc = mcm_rpcclient(agent)
    json = request.raw_post.empty? ? {} : JSON.parse(request.raw_post)
    
    args = {}
    if json.has_key?('args')
      json['args'].each do |key, value|
        args[key.to_sym] = value
      end
    end

    txid = rmq_uuid()
    audit = Actlog.new
    
    logger.info("#{txid} Received a request, parameters: "+request.raw_post)
    
    if json.has_key?('filter') && json['filter'].is_a?(Hash)
      filters = convert_filter(json['filter'])
      logger.info("#{txid} Converted filters: "+filters.inspect)
      mc.filter = filters
      audit.filters = json['filter'].to_json
    else
      logger.info("#{txid} No filters.")
    end
    
    audit.txid = txid
    audit.agent = agent
    audit.args = args.to_json
    audit.action = action
    audit.owner = current_user.name
    audit.save()
    logger.info("#{txid} Sending acknowledgement.")
    
    rmq_send(txid, { :begin => true, :action => action, :agent => agent })
    
    t = Thread.new(txid) { |ttxid|
      begin
        stat = mc.method_missing(action, args) { |noderesponse|
          rmq_send(ttxid, { :node => noderesponse })
          rl = Responselog.new
          rl.actlog = audit
          rl.name = noderesponse[:senderid]
          rl.status = noderesponse[:body][:statuscode]
          rl.statusmsg = noderesponse[:body][:statuscode]
          rl.save()
          noderesponse[:body][:data].each_pair do |k,v|
            if v.is_a?(String) or v.is_a?(Fixnum)
              ri = ReplyItem.new
              ri.responselog = rl
              ri.rkey = k
              ri.rvalue = v
              ri.save()
            end
          end
        }
        rmq_send(ttxid, { :end => 1, :stats => stat })
        audit.stats = stat.to_json
        audit.save()
      rescue => ex
        rmq_send(ttxid, { :end => 1, :error => ex.message })
      ensure
        ActiveRecord::Base.clear_active_connections!
      end
    }

    render json: { :txid => txid }.jsonize
  end
end
