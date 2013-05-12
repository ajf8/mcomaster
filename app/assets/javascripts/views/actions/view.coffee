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
MCM.Views.Layouts.Action = Backbone.Marionette.Layout.extend({
  template: HandlebarsTemplates['actions/view']

  regions: {
    requestRegion: "#actionRequestRegion",
    resultsRegion: "#actionResultsRegion",
    statsRegion: "#actionStatsRegion"
  }
    
  beginResults: (tx, msg) ->
    resultsCollection = new MCM.Collections.ActionResult([], { tx : tx })
    @results = new @options.viewClass({ tx : tx, collection : resultsCollection, ddl : @ddl })
    @resultsRegion.show(@results)
    
  receiveError: (tx, msg) ->
    @results.setError(msg)
    
  initialize: ->
    @listenTo MCM.vent, "action:beginResults", (tx, msg) =>
      @beginResults(tx, msg)
      
    @listenTo MCM.vent, "action:receiveError", (tx, msg) =>
      @receiveError(tx, msg)

    @listenTo MCM.vent, 'action:receiveDdl', (ddl) =>
      @ddl = ddl

  templateHelpers: ->
    return @options
    
  onShow: ->
    $(window).backToTop();
    @request = new MCM.Views.Layouts.ActionRequest(@options)
    @requestRegion.show(@request)
 });
