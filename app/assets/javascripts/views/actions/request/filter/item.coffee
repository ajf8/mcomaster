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
    return @model.attributes.filtertype+"-filter filter-wrapper"
    
  getRequestFilter: ->
    filterType = @model.attributes.filtertype
    if filterType == "fact"
      r = { operator : $(@$el).find(".filter-operator").val(), value : @model.attributes.term, fact : @model.attributes.term_key }
      if r.value == undefined or r.term_key == undefined or r.operator == undefined
        return undefined
      else
        return r
    else
      return $(@$el).find(".filter-string").val()
      
  # choose and then curry the template
  template: (oc) ->
    if oc.filtertype == "fact"
      return (context) ->
        context = _.extend({'filterTypeName' : 'Fact'}, oc)
        return HandlebarsTemplates['actions/request/filter/kov_item'](context)
    else if oc.filtertype == "identity"
      return (context) ->
        context = _.extend({'filterTypeName' : 'Identity'}, oc)
        return HandlebarsTemplates['actions/request/filter/str_item'](context)
    else if oc.filtertype == "agent"
      return (context) ->
        context = _.extend({'filterTypeName' : 'Agent'}, oc)
        return HandlebarsTemplates['actions/request/filter/str_item'](context)
    else if oc.filtertype == "class"
      return (context) ->
        context = _.extend({'filterTypeName' : 'Class'}, oc)
        return HandlebarsTemplates['actions/request/filter/str_item'](context)
  
  initialize: ->
    @modelBinder = new Backbone.ModelBinder()
    
  onShow: ->
    @modelBinder.bind(@model, @el)
    m = @model
    that = @
    $(@$el).find("select option").each ->
      
      if (@value == "==") or m.attributes.term_operator == @value
        $(that.$el).find("select").val(@value)
        $(that.$el).attr("selected", "selected")
      else
        $(that.$el).removeAttr("selected")
      true
    
  templateHelpers: ->
    return { cid : @model.attributes.id || @model.cid }
})