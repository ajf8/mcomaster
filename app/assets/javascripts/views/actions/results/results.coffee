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
MCM.Views.ActionResults = Backbone.Marionette.CompositeView.extend({
  template: HandlebarsTemplates['actions/results/results']
  
  itemView: MCM.Views.ActionResultItem

  itemViewContainer: "tbody"
  
  itemViewOptions: ->
    return {
      columns : @columns
      viewClass : @options.itemViewClass
    }
    
  initialize: ->
    @columns = []
    outputs = @options.ddl.actionDdl.output
    for own output of outputs
      @columns.push(_.extend({key : output}, outputs[output]))
      
    #@listenTo @collection, "add", @render
  
  setError: (error) ->
    @error = error
    @render()
    
  templateHelpers: ->
    resultCount = @collection.length
    
    return {
      error : @error,
      columns : @columns,
      resultCount : resultCount,
      hasResults : resultCount > 0
    }
});
