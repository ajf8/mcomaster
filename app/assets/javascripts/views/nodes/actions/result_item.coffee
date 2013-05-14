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
MCM.Views.NodeActionResultItem = Backbone.Marionette.ItemView.extend({
  template: HandlebarsTemplates['actions/results/vertical_result_item']

  initialize: ->
    outputs = @options.ddl.actionDdl.output
    @rows = []
    i = 0
    for own output of outputs
      v = @model.attributes.body.data[output]
      @rows.push( { kee : output, val : v.toString(), isComplex : $.isArray(v) or $.isPlainObject(v) } )

  templateHelpers: ->
    t = _.extend(@options, { rows : @rows })
    
    if @model.attributes.body.statuscode == 0
      t['icon'] = "node-icon-ok"
    else
      t['icon'] = "node-icon-fail"
      
    return t
      
  onShow: ->
    $(@el).find(".complex").each (ci, c) =>
      k = $(c).data("column")
      v = @model.attributes.body.data[k]
      $(c).renderJSON(v)
});
