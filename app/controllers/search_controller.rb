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
class SearchController < ApplicationController
  before_filter :authenticate_user!
  
  def search
    term = params[:q]
    
    nodes = $redis.keys("mcollective::facts::*#{term}*")
    agents = $redis.keys("mcollective::agent::*#{term}*")
    collectives = $redis.keys("mcollective::collective::*#{term}*")
    
    nodes.map { |n| n.gsub!(/mcollective\:\:facts\:\:/, "") }
    agents.map { |a| a.gsub!(/mcollective\:\:agent\:\:/, "") }
    collectives.map { |a| a.gsub!(/mcollective\:\:collective\:\:/, "") }
    
    results = { :node => nodes.sort, :agent => agents.sort, :collective => collectives.sort }
    images = {}
    results.keys.each do |result_type|
      images[result_type] = ActionController::Base.helpers.asset_path("#{result_type.to_s}.png")
    end
    
    render json: { :results => results, :images => images }
  end
end
