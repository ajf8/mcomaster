###
 Copyright 2013 ajf http://github.com/ajf8

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
###

#= require jquery
#= require jquery_ujs
#= require jquery.validate
#= require jquery.validate.bootstrap
#= require util/back_to_top
#= require underscore
#= require moment
#= require backbone
#= require backbone.sync.rails
#= require backbone.marionette
#= require Backbone.ModelBinder
#= require bootstrap
#= require handlebars

#= require init

#= require_tree ./helpers/
#= require_tree ./templates/
#= require_tree ./models/
#= require_tree ./collections/

#= require ./views/collectives/menu_item
#= require ./views/collectives/dropdown_item
#= require ./views/nodes/menu_item
#= require ./views/nodes/facts/fact_item
#= require ./views/nodes/actions/result_item
#= require ./views/agents/menu_item
#= require ./views/agents/dropdown_item
#= require ./views/agents/table_item
#= require ./views/actions/results/item
#= require ./views/actions/request/filter/item
#= require ./views/menu/empty_menu_item
#= require ./views/menu/loading_menu_item

#= require_tree ./views/

#= require_tree ./routers/ 

#= require_tree .
