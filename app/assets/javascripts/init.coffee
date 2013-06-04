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
window.MCM = new Backbone.Marionette.Application();

MCM.Views = {};
MCM.Views.Layouts = {};
MCM.Models = {};
MCM.Collections = {};
MCM.Routers = {};
MCM.Controllers = {};
MCM.Helpers = {};

MCM.layouts = {};

MCM.addRegions({
  mainRegion: "#mainContent"
  applicationsListRegion : "#applicationsList"
  nodesListRegion : "#nodesList"
  agentsListRegion: "#agentsList"
  agentsToolbarRegion: "#agentsToolbar"
  collectivesListRegion: "#collectivesList"
  collectivesToolbarRegion: "#collectivesToolbar"
  loggedInBarRegion : "#loggedInBar"
});

MCM.vent.on "authentication:interactive_logged_in", (user) ->
  window.location = "/#/"
  
MCM.vent.on "authentication:logged_in", (user) ->
  MCM.loggedInBarRegion.show(new MCM.Views.LoggedInBar(model : user))
  menu = $("#menuContent")
  if !menu.is(":visible")
    $("#mainContent").removeClass("span12").addClass("span9")
    menu.slideDown()

MCM.vent.on "authentication:logged_out", ->
  MCM.loggedInBarRegion.close()
  
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
    MCM.vent.trigger("authentication:logged_in", MCM.currentUser);
  else
    MCM.vent.trigger("authentication:logged_out");
  
MCM.addInitializer ->
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
  
  MCM.applications = new MCM.Collections.Applications
  applicationsMenuView = new MCM.Views.ApplicationsMenu(collection : MCM.applications) 
  MCM.applicationsListRegion.show(applicationsMenuView)
  
  MCM.vent.on "authentication:logged_in", (user) ->
    MCM.agents.fetch()
    MCM.collectives.fetch()
    MCM.nodes.fetch()
    MCM.agentsToolbarRegion.show(agentsToolbarView)
    MCM.collectivesToolbarRegion.show(collectivesToolbarView)
  
  # TODO: tidy this up, make a single view class of some sort   
  $(document).ajaxError (e, xhr, req) ->
    if MCM.currentUser == undefined or req.url == "/users/sign_in.json" or xhr.statusText == "abort"
      return
      
    loginDialogs = $(".logout-notification").length
    if xhr.status == 401 and loginDialogs < 1
      if $(".disconnect-notification").length > 0
         $(".disconnect-notification").modal('hide')

      bootbox.dialog("You have been logged out.", [{
        "label" : "Login",
        "class" : "btn-primary"
        "callback" : ->
          window.location = "/"
      }], { "classes" : "logout-notification" })
    else if xhr.status != 404 and $(".disconnect-notification").length < 1 and loginDialogs < 1 
      bootbox.dialog('<div class="reconnect"></div>You seem to have been disconnected.', [{
        "label" : "Reconnect",
        "class" : "btn-primary"
        "callback" : ->
          $.ajax '/collectives', {
            success: (rsp, check_status) ->
              Backbone.history.loadUrl(Backbone.history.fragment)
              $(".disconnect-notification").modal("hide")
            complete: (rsp, check_status) ->
              if check_status == "error"
                disconnectNotification = HandlebarsTemplates['shared/notifications']( alertType : "error", message : "unable to reconnect", noDismiss : true )
                $(".disconnect-notification .reconnect").html(disconnectNotification)
          }
          return false
      }], { "classes" : "disconnect-notification" })

$ ->
  MCM.start()
  Backbone.history.start()
