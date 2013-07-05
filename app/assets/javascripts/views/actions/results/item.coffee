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
  
  events: {
    "click a" : "openComplex"
  }
  
  # complex = objects or arrays, things which might be too
  # big to display nicely in a table. so provide a link which
  # renders the object nicely in a bootbox modal dialog
  
  openComplex: (e) ->
    k = $(e.currentTarget).data("column")
    v = @model.attributes.body.data[k]
    bootbox.dialog($('<div></div>').renderJSON(v), [{
      "label" : "Close",
      "class" : "btn-inverse"
    }]).addClass("complex-type-view-modal")
    e.preventDefault()
    
  initialize: (options) ->
    @rowItems = []
    for o in options.columns
      @rowItems.push(MCM.ResultHelpers.newRow(@model, o.key))
      
  templateHelpers: ->
    t = { rowItems : @rowItems }
    
    if @model.attributes.body.statuscode == 0
      t['icon'] = "node-icon-ok"
      if @model.attributes.body.statusmsg.length < 8
        t['badgeClass'] = "success"
    else
      t['icon'] = "node-icon-fail"
      if @model.attributes.body.statusmsg.length < 8
        t['badgeClass'] = "important"
    
    return t
});
