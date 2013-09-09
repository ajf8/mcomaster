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
class ActlogsController < ApplicationController
  before_filter :authenticate_user!
  
  require 'mcomaster/restmqclient'
  include Mcomaster::RestMQ
    
  def index
    render json: Actlog.all.to_json()
  end
  
  def show
    render json: Actlog.find(params[:id]).to_json(:include => :responselogs)
  end
  
  def replay
    id = params[:id]
    txid = rmq_uuid() 
    
    log = Actlog.find(id)
    
    rmq_send(txid, { :begin => true, :action => log.action, :agent => log.agent })
    
    Thread.new(txid) {
      begin
        log.responselogs.each do |r|
          reconstruct = {}
          reconstruct[:senderid] = r.name
          reconstruct[:senderagent] = log.agent
          data = {}
          r.reply_items.each do |ri|
            data[ri.rkey] = ri.rvalue
          end
          body = { :statuscode => r.status, :statusmsg => r.statusmsg, :data => data }
          reconstruct[:body] = body
          rmq_send(txid, { :node => reconstruct })
        end
        stats = nil
        unless log.stats.nil?
          stats = JSON.parse(log.stats)
        end
        rmq_send(txid, { :end => 1, :stats => stats } )
      rescue
        rmq_send(txid, { :end => 1, :error => ex.message })
      ensure
        ActiveRecord::Base.clear_active_connections!
      end
    }
    
    response = { :txid => txid, :args => JSON.parse(log.args) }
    unless log.filters.nil?
      response[:filters] = JSON.parse(log.filters)
    end
    render json: response.to_json
  end
end
