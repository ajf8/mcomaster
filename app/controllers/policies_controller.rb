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
class PoliciesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource

  def destroy
    Policy.find(params[:id]).destroy()
    render text: "OK"
  end

  def index
    render json: Policy.all.order("agent")
  end

  def show
    result = Policy.find(params[:id])
    render json: result.nil? ? {} : result
  end

  def create
    policy = Policy.new(policy_params)
    policy.save
    render json: policy
  end

  def update
    policy = Policy.find(params[:id])
    policy.update(policy_params)
    policy.save()
    render json: policy
  end

  private

  def policy_params
    params.permit(:agent, :action_name, :callerid, :policy)
  end
end
