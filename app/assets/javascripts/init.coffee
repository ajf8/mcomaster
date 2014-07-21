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
window.MCM = new Backbone.Marionette.Application()

# Namespaces

MCM.Views = {}
MCM.Views.Layouts = {}
MCM.Models = {}
MCM.Collections = {}
MCM.Routers = {}
MCM.Controllers = {}
MCM.Helpers = {}
MCM.layouts = {}
MCM.Debug = {}

# Visual regions of the application, mapped to CSS selectors
# eg. used as MCM.mainRegion.show(view)

MCM.addRegions({
  mainRegion: "#mainContent"
  applicationsListRegion : "#applicationsList"
  nodesListRegion : "#nodesList"
  agentsListRegion: "#agentsList"
  agentsToolbarRegion: "#agentsToolbar"
  collectivesListRegion: "#collectivesList"
  collectivesToolbarRegion: "#collectivesToolbar"
  applicationsToolbarRegion: "#applicationsToolbar"
  adminToolbarRegion: "#adminToolbar"
  loggedInBarRegion : "#loggedInBar"
})

# go to home page if an interactive login succeeds
MCM.vent.on "authentication:interactive_logged_in", (user) ->
  window.location = "/#/"

# show navigation menu on login, and the logged in bar at the top
MCM.vent.on "authentication:logged_in", (user) ->
  MCM.loggedInBarRegion.show(new MCM.Views.LoggedInBar(model : user))
  menu = $("#menuContent")
  if !menu.is(":visible")
    $("#mainContent").removeClass("span12").addClass("span9")
    menu.slideDown()

MCM.vent.on "authentication:logged_out", ->
  MCM.loggedInBarRegion.close()
  MCM.adminToolbarRegion.close()
  
  if Backbone.history.fragment != "login"
    window.location = "/#/login"
  
MCM.bind "initialize:after", ->
  MCM.remoteConfig = MCM.remoteConfig || {}
  if MCM.remoteConfig.refresh_interval and MCM.remoteConfig.refresh_interval > 0
    setInterval ->
      MCM.agents.fetch()
      MCM.collectives.fetch()
      MCM.nodes.fetch()
      return true
    , (MCM.remoteConfig.refresh_interval * 1000)

  if(MCM.currentUser)
    MCM.vent.trigger("authentication:logged_in", MCM.currentUser)
  else
    MCM.vent.trigger("authentication:logged_out")
  
MCM.addInitializer ->
  unless MCM.remoteConfig.noNodeMenu
    MCM.nodes = new MCM.Collections.Node
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
  
  MCM.applications = new MCM.Collections.Applications
  applicationsMenuView = new MCM.Views.ApplicationsMenu(collection : MCM.applications)
  MCM.applicationsListRegion.show(applicationsMenuView)
  applicationsToolbarView = new MCM.Views.ApplicationsDropdown(collection : MCM.applications)
  MCM.applicationsToolbarRegion.show(applicationsToolbarView)

  adminToolbarView = new MCM.Views.AdminDropdown

  MCM.app_settings = new MCM.Collections.AppSettings

  MCM.vent.on "authentication:logged_in", (user) ->
    MCM.agents.fetch()
    MCM.collectives.fetch()
    MCM.nodes.fetch()
    MCM.agentsToolbarRegion.show(agentsToolbarView)
    MCM.collectivesToolbarRegion.show(collectivesToolbarView)

    if (user.attributes.is_admin == true)
      MCM.adminToolbarRegion.show(adminToolbarView)

$ ->
  MCM.start()
  Backbone.history.start()
