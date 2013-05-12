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
MCM.Views.ActionRequestFilterForm = Backbone.Marionette.CompositeView.extend({
  template: HandlebarsTemplates['actions/request/filter/filter']
  
  itemViewContainer: "#filterContainer"
  itemView: MCM.Views.ActionRequestFilterItem
  
  events : {
    "click #addFactFilterBtn" : "addFactFilter"
    "click #addIdentityFilterBtn" : "addIdentityFilter"
    "click #addAgentFilterBtn" : "addAgentFilter"
    "click #addClassFilterBtn" : "addClassFilter"
    "click .filter-remove-icon" : "filterRemove"
  }
  
  initialize: ->
    @idCounter = 0

  getRequestFilter: ->
    filters = {}
    $.each @children._views, (key, val) ->
      f = val.getRequestFilter()
      if f != undefined
        filterType = val.model.attributes.filterType
        if filters[filterType] == undefined
          filters[filterType] = []
      
        filters[filterType].push(f)
        
    return filters
      
  filterRemove: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data("id");
    item = @collection.get(id);
    @collection.remove(item)
    @render()
    
  addFilter: (item) ->
    @collection.add(item)
    @render()
  
  newFilter: (filterType) ->
    return new MCM.Models.ActionRequestFilter({'id' : "filter"+@idCounter++, 'filterType' : filterType})
    
  addFactFilter: (e) ->
    @addFilter(@newFilter('fact'))
    e.preventDefault()
    
  addIdentityFilter: (e) ->
    e.preventDefault()
    @addFilter(@newFilter('identity'))

  addClassFilter: (e) ->
    e.preventDefault()
    @addFilter(@newFilter('class'))

  addAgentFilter: (e) ->
    @addFilter(@newFilter('agent'))
    e.preventDefault()
    
  templateHelpers: ->
    { 'hasFilters' : @collection.size() > 0 }
    
  onShow: ->
    $('#requestTabs a').click (e) ->
      e.preventDefault();
      $(this).tab('show');
});
