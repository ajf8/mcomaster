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
MCM.Views.Layouts.ActionResults = Backbone.Marionette.LayoutView.extend({
  template: HandlebarsTemplates['actions/results/layout']
  
  regions: {
    statsRegion: "#actionStats"
    resultsRegion: "#actionResultsCollection"
    resultsPaginatorRegion : "#actionResultsPaginator"
    aggregatesRegion: "#actionAggregates"
  }

  setError: (err) ->
    @results.setError(err)
  
  receiveStats: (tx, msg) ->
    if tx.txid == @options.tx.txid
      statsModel = new MCM.Models.ActionResultsStats(msg)
      @stats = new MCM.Views.ActionResultsStats(_.extend(@options, model : statsModel))
      @statsRegion.show(@stats)
      @aggregates = new MCM.Views.ActionResultsAggregates(_.extend(@options, model : statsModel))
      @aggregatesRegion.show(@aggregates)
    
  addPaginatorControls: (tx) ->
    paginatorView = new MCM.Views.Paginator(collection : @options.collection )
    @resultsPaginatorRegion.show(paginatorView)
    
  initialize: ->
    @listenTo MCM.vent, "action:receiveStats", @receiveStats
    @listenTo @options.collection, "resultsPaginator:needsControls", @addPaginatorControls

  onShow: ->
    @results = new MCM.Views.ActionResults(@options)
    @resultsRegion.show(@results)
})
