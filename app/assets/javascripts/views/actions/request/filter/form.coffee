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
# A CompositeView which has buttons for creating new items, and displaying them
MCM.Views.ActionRequestFilterForm = Backbone.Marionette.CompositeView.extend({
  template: HandlebarsTemplates['actions/request/filter/filter']
  childViewContainer: "#filterContainer"
  childView: MCM.Views.ActionRequestFilterItem
  
  # serialize all the filters into the object the
  # server API expects
  getRequestFilter: ->
    filters = {}
    $.each @children._views, (key, val) ->
      f = val.getRequestFilter()
      if f != undefined
        filterType = val.model.attributes.filtertype
        if filters[filterType] == undefined
          filters[filterType] = []
      
        filters[filterType].push(f)
        
    return filters
  
  onShow: ->
    $('#requestTabs a').click (e) ->
      e.preventDefault()
      $(this).tab('show')
})