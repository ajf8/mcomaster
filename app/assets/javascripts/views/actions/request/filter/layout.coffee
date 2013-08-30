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
MCM.Views.Layouts.ActionRequestFilter = Backbone.Marionette.Layout.extend({
  template: HandlebarsTemplates['actions/request/filter/layout']
  
  regions: {
    remoteRegion: "#remoteFilters"
    formRegion: "#filterForm"
    resultsRegion: "#filterResults"
  }
  
  events : {
    "click .filter-discover-button" : "doDiscovery"
    "click #remoteFilters li > a" : "getFilter"
    "click #addFactFilterBtn" : "addFactFilter"
    "click #addIdentityFilterBtn" : "addIdentityFilter"
    "click #addAgentFilterBtn" : "addAgentFilter"
    "click #addClassFilterBtn" : "addClassFilter"
    "click a.filter-member-remove-link" : "filterMemberRemove"
    "click a.filter-remove-link" : "filterRemove"
    "click a.save-link" : "filterSave"
    "click a.add-link" : "filterAdd"
  }
  
  filterAdd: (e) ->
    e.preventDefault()
    @currentModel = new MCM.Models.Filter
    @setForm()
    
  filterSave: (e) ->
    e.preventDefault()
    that = @
    if @currentModel.attributes.name == undefined
      bootbox.prompt "Name for new filter", (result) ->
        if result
          that.setActiveName(result)
          that.currentModel.set(name : result)
          that.collection.add(that.currentModel)
          that.currentModel.save()
          #that.collection.fetch()
    else
      @currentModel.save()
      @collection.fetch()   
    
  filterRemove: (e) ->
    if @currentModel != undefined
      @currentModel.destroy()
    @currentModel = new MCM.Models.Filter
    @setForm()
    
  filterMemberRemove: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data("id")
    item = @currentModel.attributes.filter_members.get(id)
    item.destroy()
    
  addFilter: (item) ->
    @currentModel.attributes.filter_members.add(item)
  
  newFilter: (filterType) ->
    # needs an ID, just an incrementing counter, for removal
    # filterType chooses where it goes in the top level of
    # the filter object
    fm = new MCM.Models.FilterMember(filtertype : filterType )
    @currentModel.attributes.filter_members.add(fm)
    
  addFactFilter: (e) ->
    e.preventDefault()
    @newFilter('fact')

  addIdentityFilter: (e) ->
    e.preventDefault()
    @newFilter('identity')

  addClassFilter: (e) ->
    e.preventDefault()
    @newFilter('class')

  addAgentFilter: (e) ->
    e.preventDefault()
    @newFilter('agent')
  
  setActiveName: (name) ->
    $(@$el).find("span.dropdown-active").html(name)
    
  setForm: ->
    @form = new MCM.Views.ActionRequestFilterForm(collection : @currentModel.attributes.filter_members)
    @listenTo @currentModel.attributes.filter_members, "add remove", @decideWellVisibility
    @formRegion.show(@form)
    if @currentModel == undefined or @currentModel.attributes.name == undefined
      @setActiveName("Unnamed filter")
    else
      @setActiveName(@currentModel.attributes.name)
    @decideWellVisibility()
     
  getFilter: (e) ->
    e.preventDefault()
        
    id = $(e.currentTarget).data("id")
    @currentModel = @collection.get(id)
    
    that = @
    
    if @currentModel
      @setForm()
      
  getRequestFilter: ->
    if @form != undefined
      return @form.getRequestFilter()
    else
      return {}

  doDiscovery: (e) ->
    filter = @form.getRequestFilter()
    e.preventDefault()
    
    @resultsRegion.close()
    
    $.ajax({
      type: "POST"
      url: "/discover"
      dataType: "json"
      data: JSON.stringify({ filter : filter })
      success: (data) =>
        @results = new MCM.Views.ActionRequestFilterResults(data)
        @resultsRegion.show(@results)
    })

  decideRemotesVisibility: ->
    if @collection.size() > 0
      $(@$el).find("div.remote-filters-group").show()
    else
      $(@$el).find("div.remote-filters-group").hide()
    
  decideWellVisibility: ->
    if @currentModel.attributes.filter_members.size() > 0
      $("#filterFormContainer").show()
    else 
      $("#filterFormContainer").hide()

  onShow: ->
    @idCounter = 0
    @collection = @options.collection
    @listenTo @collection, "reset add remove", @decideRemotesVisibility
    @remote = new MCM.Views.ActionRequestRemoteFilters(collection : @collection)
    @remoteRegion.show(@remote)
    @currentModel = new MCM.Models.Filter
    #@collection.add(@currentModel)
    @setForm()
    @collection.fetch()

  templateHelpers: ->
    return @options
})
