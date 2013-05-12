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
MCM.Views.ActionResultItem = Backbone.Marionette.ItemView.extend({
  tagName: "tr",
  template: HandlebarsTemplates['actions/results/table_result_item']
  
  initialize: (options) ->
    @rowItems = []
    for o in options.columns
      @rowItems.push(@model.attributes.body.data[o.key].toString())
      
  templateHelpers: ->
    t = { rowItems : @rowItems }
    
    if @model.attributes.body.statuscode == 0
      t['icon'] = "node-icon-ok"
    else
      t['icon'] = "node-icon-fail"
    
    return t
});
