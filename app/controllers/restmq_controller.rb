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
class RestmqController < ApplicationController
  require 'mcomaster/restmqclient'
  include Mcomaster::RestMQ
  
  before_filter :set_cache_buster, :authenticate_user!
  
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
   
  def index
    #b = $redis.smembers QUEUESET
    
    #if b.nil?
    #  render text: "Not found", :status => 404
    #  return
    #end
    
    #b.map! do |q| q = '/mq/'+q end
  
    #render json: b.jsonize
    return []
  end
    
  def get
    queue = params[:queue]
    
    if queue.nil?
      render text: "Not found", :status => 404
      return
    end
      
    queue = queue + QUEUE_SUFFIX
    response = []
    
    while true
      b = $redis.rpop queue
    
      if b.nil?
        break
      end
    
      v = $redis.get b
      
      response.push({ :value => v.nil? ? nil : JSON.parse(v), :key => b })
    end
    
    if response.length < 1
      render text: 'Not found (empty queue)', :status => 404
      return
    end
    
    render json: response.jsonize
  end
  
  def post
    queue = params[:queue]
    value = request.raw_post
    
    if queue.nil?
      render text: "Not Found", :status => 404
    end
    
    render text: rmq_send(queue, value)
  end
end