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
class DiscoverController < ApplicationController
  require 'mcomaster/mcclient'
  require 'mcomaster/restmqclient'

  include Mcomaster::McClient
  include Mcomaster::RestMQ

  before_filter :authenticate_user!

  def discover
    json = request.raw_post.empty? ? {} : JSON.parse(request.raw_post)
    mc = mcm_rpcclient("rpcutil")

    if json.has_key?('filter') && json['filter'].is_a?(Hash)
      filters = convert_filter(json['filter'])
      logger.info("Doing discovery with filters: "+filters.inspect)
      mc.filter = filters
    else
      logger.info("Doing discovery with no filters.")
    end

    discover_result = mc.discover()
    rest_result = { :nodes => discover_result }

    render json: rest_result.jsonize
  end
end