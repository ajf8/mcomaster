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

# A layout for a single action. Includes the form, optional filters,
# and displays the results.

# The results view class is provided in @options.resultsVIewClass.
# To allow for the result attributes to be shown in columns (many results)
# or rows (single result).

MCM.Views.Layouts.Action = Backbone.Marionette.Layout.extend({
  template: HandlebarsTemplates['actions/view']

  regions: {
    requestRegion: "#actionRequestRegion",
    resultsRegion: "#actionResultsRegion",
    statsRegion: "#actionStatsRegion"
  }
    
  beginResults: (tx, msg) ->
    @txid = tx.txid
    resultsCollection = new MCM.Collections.ActionResult([], { tx : tx })
    filteredResultsCollection = new MCM.Collections.Paginator([], { original : resultsCollection, perPage : MCM.remoteConfig.defaultPerPage })
    @results = new @options.resultsViewClass({ tx : tx, collection : filteredResultsCollection, ddl : @ddl, agent : @options.agent, action : @options.id })
    @resultsRegion.show(@results)
    
  receiveError: (tx, msg) ->
    if @txid == tx.txid
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
    $(window).backToTop()
    @request = new @options.requestViewClass(@options)
    @requestRegion.show(@request)
})
