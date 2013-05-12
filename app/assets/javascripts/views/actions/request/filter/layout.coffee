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
    formRegion: "#filterForm"
    resultsRegion: "#filterResults"
  }
  
  events : {
    "click .filter-discover-button" : "doDiscovery"
  }
  
  getRequestFilter: ->
    return @form.getRequestFilter()

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
    });

  onShow: ->
    @form = new MCM.Views.ActionRequestFilterForm(@options)
    @formRegion.show(@form)
})
