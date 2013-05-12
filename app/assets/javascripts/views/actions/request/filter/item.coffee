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
MCM.Views.ActionRequestFilterItem = Backbone.Marionette.ItemView.extend({
  className: ->
    return @model.attributes.filterType+"-filter filter-wrapper"
    
  getRequestFilter: ->
    filterType = @model.attributes.filterType
    if filterType == "fact"
      r = { operator : $(@$el).find(".filter-operator").val(), value : @model.attributes.value }
      r[@model.attributes.filterType] = @model.attributes[@model.attributes.filterType]
      if r.value == undefined or r[@model.attributes.filterType] == undefined or r.operator == undefined
        return undefined
      else
        return r
    else
      return $(@$el).find(".filter-string").val()
      
  # choose and then curry the template
  template: (oc) ->
    if oc.filterType == "fact"
      return (context) ->
        context = _.extend({'filterTypeName' : 'Fact'}, oc)
        return HandlebarsTemplates['actions/request/filter/kov_item'](context)
    else if oc.filterType == "identity"
      return (context) ->
        context = _.extend({'filterTypeName' : 'Identity'}, oc)
        return HandlebarsTemplates['actions/request/filter/str_item'](context)
    else if oc.filterType == "agent"
      return (context) ->
        context = _.extend({'filterTypeName' : 'Agent'}, oc)
        return HandlebarsTemplates['actions/request/filter/str_item'](context)
    else if oc.filterType == "class"
      return (context) ->
        context = _.extend({'filterTypeName' : 'Class'}, oc)
        return HandlebarsTemplates['actions/request/filter/str_item'](context)
  
  initialize: ->
    @modelBinder = new Backbone.ModelBinder();
    
  onShow: ->
    @modelBinder.bind(@model, @el)
    
  templateHelpers: ->
    return @options
})
