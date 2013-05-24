MCM.module "Plugins.Shell", (ShellPlugin, App, Backbone, Marionette, $, _) ->
  "use strict"

  ShellPlugin = {}

  ShellPlugin.RequestView = Marionette.Layout.extend({
    regions : { 
      filterRegion: "#requestFilterRegion"
      termRegion : "#term"
    }

    template: HandlebarsTemplates["plugins/shell/request"]

    initialize: ->
      @listenTo(MCM.vent, "action:beginResults", @onBeginResults)
      @listenTo(MCM.vent, "action:receiveResult", @onReceiveResult)
      @listenTo(MCM.vent, "action:receiveStats", @onReceiveStats)

    onReceiveStats: (tx, msg) ->
      @term.echo "[1;33m *** Ran on "+msg.responses+" hosts in "+msg.totaltime.toFixed(3)+" seconds[0m .. [1;32m"+msg.okcount+" OK[0m, [1;31m"+msg.failcount+" Failed[0m\n"
      
    onBeginResults: (tx, msg) ->
      @term.echo "Command acknowledged by mcomaster .. "+tx.txid+"\n"
    
    onReceiveResult: (tx, msg) -> 
      statusColor = ""
      statusMsg = "Exit code = "+msg.body.statuscode
      if msg.body.statuscode == 0
        statusColor = "[1;32m"
      else
        statusColor = "[1;31m"
        
      if msg.body.statuscode == 0 and msg.body.statusmsg != ""
        statusMsg = statusMsg + " (" + msg.body.statusmsg+")"
        
      @term.echo("[1;34m"+msg.senderid+"[0m  ##  "+statusColor+statusMsg+"[0m")
      @term.echo("")
      if msg.body.data.stdout != undefined and msg.body.data.stdout != null and msg.body.data.stdout != ""
        @term.echo(msg.body.data.stdout)
      else
        @term.echo("(no output)")

      if msg.body.data.stderr != undefined and msg.body.data.stderr != null and  msg.body.data.stderr != ""
        @term.echo("[1;31mstderr: ")
        @term.echo(msg.body.data.stderr+"[0m")
            
    onCommand: (command, term) ->
      if command == ""
        return
        
      filter = @options.submissionArgs
      if filter == undefined && @filterView != undefined
        filter = {}
        filter['filter'] = @filterView.getRequestFilter()
           
      MCM.Client.submitAction {
        formData : _.extend(filter, { args : { cmd : command } })
        agent : "shell"
        action : "execute"
      }
      return

    onShow: ->
      if @options.filterCollection and @options.submissionArgs == undefined
        @filterView = new MCM.Views.Layouts.ActionRequestFilter({'collection' : @options.filterCollection})
        @filterRegion.show(@filterView)

      @term = $("#term").terminal $.proxy(@onCommand, @), { prompt: @options.prompt, name: 'test', greetings : "" }
      $("#termWrapper").resizable()
      
    templateHelpers: ->
      _.extend @options, {
        includeFilters : @options.submissionArgs == undefined
      }
  })
    
  ShellPlugin.Router = Backbone.Router.extend({
    routes: {
      "p/shell" : "shellAction",
      "p/shell/node/:node" : "shellNodeAction"
    }
            
    shellAction: ->
      filterCollection = new MCM.Collections.ActionRequestFilter
      view = new ShellPlugin.RequestView({ filterCollection : filterCollection, prompt : "# " })
      MCM.mainRegion.show(view);
      
    shellNodeAction: (node) ->
      submissionArgs = {
        filter: {
          identity : [ node ]
        }
      }

      view = new ShellPlugin.RequestView {
        submissionArgs : submissionArgs,
        prompt : node+"# " 
      }
      
      MCM.mainRegion.show(view)
  })
    
  ShellPlugin.onlyIf = ->
    return MCM.agents.get("shell") != undefined
    
  MCM.addInitializer ->
    new ShellPlugin.Router();