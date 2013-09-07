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

require 'mcomaster/mcclient'

class DdlsController < ApplicationController
  include Mcomaster::McClient
  
  before_filter :authenticate_user!
  
  def validate
    response = {}
    if request.request_parameters.size < 1
      render text: "bad query"
    end
    
    ddl = get_real_ddl(params[:ddl_id])
    interface = ddl.action_interface(params[:mcaction])
    
    request.request_parameters.each_pair{|k,v|
      ksym = k.to_sym
      begin 
        ktype = interface[:input][ksym][:type]
        if ktype == :boolean
          if v == "true"
            v = true
          elsif v == "false"
            v = false
          else
            raise MCollective::DDLValidationError, "expected boolean"
          end
        elsif ktype == :integer
          v = v.to_i
        end
        ddl.validate_input_argument(interface[:input], ksym, v)
        render text: "true"
      rescue MCollective::DDLValidationError => ex
        render text: ex.message
      end
    }
  end
end
