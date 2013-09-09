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
class FiltersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    render json: Filter.all.to_json(:include => :filter_members)
  end
  
  def show
    render json: Filter.find(params[:id])
  end
  
  def create
    f = Filter.new
    unless params[:filter_members_attributes].nil?
      f.filter_members_attributes = params[:filter_members_attributes]
    end
    f.name = params[:name]
    f.save() 
    render json: f.to_json(:include => :filter_members)
  end
  
  def destroy
    render json: Filter.find(params[:id]).destroy()
  end
  
  def update
    model = Filter.find(params[:id])
    unless params[:filter_members_attributes].nil?
      model.filter_members_attributes = params[:filter_members_attributes]
    end
    model.name = params[:name]
    model.save()
    render json: model.to_json(:include => :filter_members)
  end
end
