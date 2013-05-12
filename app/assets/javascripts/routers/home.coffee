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
MCM.Routers.Home = Backbone.Router.extend({
  routes: {
    "": "home"
    #"contact": "contact"
    #"employees/:id": "employeeDetails"
  }

  initialize: ->
    unless MCM.remoteConfig.noNodeMenu
      MCM.nodes = new MCM.Collections.Node
      #nodesMenuPaginator = new MCM.Collections.Paginator(MCM.nodes, 0, 1)
      nodesView = new MCM.Views.NodesMenu(collection : MCM.nodes)
      MCM.nodesListRegion.show(nodesView)
    
    MCM.collectives  = new MCM.Collections.Collective 
    collectivesMenuView = new MCM.Views.CollectivesMenu(collection : MCM.collectives)
    collectivesToolbarView = new MCM.Views.CollectivesDropdown(collection : MCM.collectives)
    MCM.collectivesListRegion.show(collectivesMenuView)
    
    MCM.agents = new MCM.Collections.Agent
    agentsView = new MCM.Views.AgentsMenu(collection : MCM.agents)
    agentsToolbarView = new MCM.Views.AgentsDropdown(collection : MCM.agents)
    MCM.agentsListRegion.show(agentsView)
    
    MCM.vent.on "authentication:logged_in", (user) ->
      MCM.agents.fetch()
      MCM.collectives.fetch()
      MCM.nodes.fetch()
      MCM.agentsToolbarRegion.show(agentsToolbarView)
      MCM.collectivesToolbarRegion.show(collectivesToolbarView)
      
  home: ->
    homeView = new MCM.Views.AgentsHomeList(collection : MCM.agents)
    MCM.mainRegion.show(homeView)
    
    #$("#content").html(@homeView.el)
    #@homeView.select('home-menu');
});

MCM.addInitializer ->
  MCM.homeController = new MCM.Routers.Home()  
