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
MCM.module "Plugins.Shell", (ShellPlugin, App, Backbone, Marionette, $, _) ->
  ShellPlugin.AbstractRequestView = Marionette.LayoutView.extend({
    regions : {
      filterRegion: "#shellFilterRegion"
      termRegion : "#term"
    }

    template: HandlebarsTemplates["plugins/shell/request"]

    initialize: ->
      @listenTo(MCM.vent, "action:beginResults", @onBeginResults)
      @listenTo(MCM.vent, "action:receiveResult", @onReceiveResult)
      @listenTo(MCM.vent, "action:receiveStats", @onReceiveStats)
      @listenTo(MCM.vent, "action:receiveError", @onReceiveError)

    getFilter: ->
      return @options.filter || {}

    onReceiveError: (tx, msg) ->
      @term.echo "[1;31m *** Error: "+msg+"[0m"
      @term.echo " "

    onReceiveStats: (tx, msg) ->
      @term.echo "[1;33m *** Ran on "+msg.responses+" hosts in "+msg.totaltime.toFixed(3)+" seconds[0m .. [1;32m"+msg.okcount+" OK[0m, [1;31m"+msg.failcount+" Failed[0m\n"

    onBeginResults: (tx, msg) ->
      @term.echo "Command acknowledged by mcomaster .. "+tx.txid+"\n"

    getStatusColor: (msg) ->
      if msg.body.statuscode == 0
        return "[1;32m"
      else
        return "[1;31m"

     getHostLine: (msg) ->
      statusColor = @getStatusColor(msg)
      statusMsg = "Exit code = "+msg.body.statuscode

      if msg.body.statuscode == 0 and msg.body.statusmsg != ""
        statusMsg = statusMsg + " (" + msg.body.statusmsg+")"

      return "[1;34m"+msg.senderid+"[0m  ##  "+statusColor+statusMsg+"[0m"

    onCommand: (command, term) ->
      console.log("implement me...")

    onShow: ->
      if @options.filterCollection
        @filterView = new MCM.Views.Layouts.ActionRequestFilter({collection : @options.filterCollection })
        @filterRegion.show(@filterView)

      @term = $("#term").terminal $.proxy(@onCommand, @), { prompt: @options.prompt, name: 'test', greetings : "" }
      $("#termWrapper").resizable()

    templateHelpers: ->
      _.extend @options, {
        includeFilters : @options.filterCollection != undefined
      }
  })

  ShellPlugin.GenericRequestView = ShellPlugin.AbstractRequestView.extend({
    usage: ->
      @term.echo("[1;31mThis shell will only execute the "+@options.id+" action of the "+@options.agent+" agent. To execute another action, navigate to it.")
      @term.echo(" ")
      @term.echo(@ddl.action+" - "+@ddl.actionDdl.description)
      example = @ddl.action
      for own key of @ddl.actionDdl.input
        i = @ddl.actionDdl.input[key]
        @term.echo("  * "+key+" - "+i.description+" ("+i.type+")")
        example = example + " <" + key + "=" + i.type + ">"
        @term.echo(" ")
      @term.echo("usage: "+example)
      @term.echo(" ")

    getFilter: ->
      if @options.filterView
        return @options.filterView.getRequestFilter()
      else
        return {}

    onCommand: (command, term) ->
      if command == ""
        return

      args = command.match(/('[^']+'|"[^"]+"|[^ ]+)/g)
      if args.length < 1
        return

      if args[0] != @options.id
        @usage()
        return

      agentArgs = {}
      i = 1
      while i < args.length
        args[i] = args[i].replace(/^"/, "").replace(/"$/, "")
        if matches = args[i].match(/^(.+?)=(.+)/)
          agentArgs[matches[1]] = matches[2]
        i++

      MCM.Client.submitAction {
        filter : @getFilter()
        args : agentArgs
        agent : @options.agent
        action : args[0]
        ddl : @ddl
      }

      return

    receiveDdl: (ddl) ->
      @ddl = ddl
      @usage()

    initialize: ->
      ShellPlugin.AbstractRequestView.prototype.initialize.call(this)
      @listenTo MCM.vent, "action:receiveDdl", @receiveDdl

    onReceiveResult: (tx, msg) ->
      @term.echo(@getHostLine(msg))
      for o in @ddl.columns
        @term.echo("  "+o.display_as+": "+msg.body.data[o.key])
      @term.echo(" ")

    onShow: ->
      ShellPlugin.AbstractRequestView.prototype.onShow.call(this)
      @term.echo("Receiving DDL...")
      @term.echo(" ")
  })
