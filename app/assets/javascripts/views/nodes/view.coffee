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
MCM.Views.Node = Backbone.Marionette.Layout.extend({
  template: HandlebarsTemplates['nodes/layout']
  
  regions: {
    #summaryRegion : "#nodeSummary"
    factsRegion: "#nodeFacts"
    runRegion : "#nodeRun"
    #shellRegion: "#nodeShell"
  }
  
  viewName : "NodeView"
  
  onShow: ->
    @factsView = new MCM.Views.NodeFacts(model : @model)

    $('#nodeTabs a').click (e) ->
      e.preventDefault();
      $(this).tab('show');

    @factsRegion.show(@factsView)
    @runRegion.show(@runView)
    
    #shellView = new MCM.Plugins.Shell.GenericRequestView({ agent : @options.agent, action : @options.action, filter : @options.filter })
    #@shellRegion.show(shellView)

    $(@activeTabSelector).tab('show')

  setTab: (selector) ->
    @activeTabSelector = selector
    $(@activeTabSelector).tab('show')
});
