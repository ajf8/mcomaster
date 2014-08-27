MCM.module "Apps.Shell", (ShellApp, App, Backbone, Marionette, $, _) ->
  # this app view extends a view in a plugin, but it doesn't have to
  
  ShellApp.ShellAgentRequestView = App.module("Plugins.Shell").AbstractRequestView.extend({
    onReceiveResult: (tx, msg) ->
      # display coloured hostname and exit code
      @term.echo(@getHostLine(msg))
      @term.echo("")
      
      if msg.body.data.stdout != undefined and msg.body.data.stdout != null and msg.body.data.stdout != ""
        @term.echo(msg.body.data.stdout)
      else
        @term.echo("(no output)")
        
      if msg.body.data.stderr != undefined and msg.body.data.stderr != null and  msg.body.data.stderr != ""
        @term.echo("[1;31mstderr: ")
        @term.echo(msg.body.data.stderr)
    
    # either get filter from the options (node view) or from the widget
    getFilter: ->
      return @options.filter || @filterView.getRequestFilter()
      
    onCommand: (command, term) ->
      if command == ""
        return
           
      MCM.Client.submitAction {
        filter : @getFilter()
        agent : "shell"
        action : "run"
        args : { command : command }
        ddl : ShellApp.ddl
      }
      return
  })
  
  ShellApp.Router = Backbone.Router.extend({
    routes: {
      "app/shell" : "shellAction",
      "app/shell/node/:node" : "shellNodeAction"
    }
    
    # open the shell agent request view with a filter collection
    # this causes filters to be displayed
    
    shellAction: ->
      filterCollection = new MCM.Collections.Filter
      filterCollection.fetch()
      view = new ShellApp.ShellAgentRequestView({ filterCollection : filterCollection, prompt : "# " })
      MCM.mainRegion.show(view)
    
    # node specific view, so create with filter and prompt
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

  # once the module is loaded, listen to agents being added
  # check for the agent this application will interact with
  ShellApp.on "start", ->
    @listenTo MCM.agents, "add", (model) ->
      if model.attributes.id == "shell" and model.attributes.ddl.meta.author == "Puppet Labs"
        @ddl = model.attributes.ddl
        MCM.applications.add(new MCM.Models.Application( { id : "shell", name : "Shell", icon : "terminal24", node_template : "applications/shell_node", node_must_have : "shell" } ))
    
  MCM.addInitializer ->
    new ShellApp.Router()