MCM.module "Apps.Shell", (ShellApp, App, Backbone, Marionette, $, _) ->
  ShellApp.ShellAgentRequestView = App.module("Plugins.Shell").AbstractRequestView.extend({
    onReceiveResult: (tx, msg) -> 
      @term.echo(@getHostLine(msg))
      @term.echo("")
      
      if msg.body.data.stdout != undefined and msg.body.data.stdout != null and msg.body.data.stdout != ""
        @term.echo(msg.body.data.stdout)
      else
        @term.echo("(no output)")
        
      if msg.body.data.stderr != undefined and msg.body.data.stderr != null and  msg.body.data.stderr != ""
        @term.echo("[1;31mstderr: ")
        @term.echo(msg.body.data.stderr)
    
    getFilter: ->
      return @filterView.getRequestFilter()
      
    onCommand: (command, term) ->         
      if command == ""
        return
           
      MCM.Client.submitAction {
        filter : @getFilter()
        agent : "shell"
        action : "execute"
        args : { cmd : command, full : true } 
      }
      return
  });
  
  ShellApp.Router = Backbone.Router.extend({
    routes: {
      "app/shell" : "shellAction",
      "app/shell/node/:node" : "shellNodeAction"
    }
            
    shellAction: ->
      filterCollection = new MCM.Collections.ActionRequestFilter
      view = new ShellApp.ShellAgentRequestView({ filterCollection : filterCollection, prompt : "# " })
      MCM.mainRegion.show(view);
      
    shellNodeAction: (node) ->
      filter = {
        identity : [ node ]
      }

      view = new ShellApp.ShellAgentRequestView {
        cancelUrl : "/#/node/"+node
        filter : filter
        prompt : node+"# "
      }
      
      MCM.mainRegion.show(view)
  })

  ShellApp.on "start", ->
    @listenTo MCM.agents, "add", (model) ->
      if model.attributes.id == "shell" and model.attributes.meta.author == "Jeremy Carroll"
        MCM.applications.add(new MCM.Models.Application( { id : "shell", name : "Shell", icon : "terminal24", node_template : "applications/shell_node", node_must_have : "shell" } )) 
    
  MCM.addInitializer ->
    new ShellApp.Router();