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
MCM.Routers.Action = Backbone.Router.extend({
  routes: {
    "action/:agent/:id": "showAction"
  }
  
  initialize: ->
    @listenTo(MCM.vent, "action:submit", @onActionSubmit)
  
  onActionSubmit: (submission) ->
    that = @
    formData = submission.args || {}
    formData.args = {}
    _.each(submission.form.serializeArray(), (x) ->
      input_type = submission.ddl.input[x.name].type
      if input_type == "boolean"
        if x.value == "true"
          x.value = true
        else if x.value == "false"
          x.value = false
          
      formData['args'][x.name] = x.value
    )

    $.ajax({
      type: "POST"
      url: "/execute/"+submission.agent+"/"+submission.action 
      dataType: "json"
      data: JSON.stringify(formData)
      success: (data) ->
        that.receiveTxn(data)
    });
    
  txGet: (tx, options) ->      
    if !tx.getCount
      tx.getCount = 0
      tx.msgCount = 0
      
    $.ajax(_.extend({
      url: "/mq/"+tx.txid+"/"+tx.getCount
      dataType: "json"
    }, options))
    
    tx.getCount++
    
  receiveTxn: (tx) ->
    @txGet tx, {
      success: (rdata) =>
        for envelope in rdata
          msg = envelope.value

          if msg.begin 
            MCM.vent.trigger("action:beginResults", tx, msg.begin)          
          else if msg.node
            msg.node.id = envelope.key
            MCM.vent.trigger("action:receiveResult", tx, msg.node)
          else if msg.error
            MCM.vent.trigger("action:receiveError", tx, msg.error)
          else if msg.stats
            MCM.vent.trigger("action:receiveStats", tx, msg.stats)
          
          tx.msgCount++
          
          if msg.end
            return
            
        setTimeout =>      
          @receiveTxn(tx)
        , 400
          
      error: (rdata) =>
        setTimeout =>
          @receiveTxn(tx)
        , 400
    }

  transformDdl: (ddl, agent, action) ->
    actionDdl = ddl['actions'][action]
    
    if !actionDdl
      return
      
    validationRules = { };

    for own ddlKey of actionDdl.input
      validationRules[ddlKey] = {
        remote : {
          type : "POST"
          dataType : "text"
          url : "/ddls/"+agent+"/validate/"+action
        }
      }
      
      if actionDdl.input[ddlKey]['optional']
        validationRules[ddlKey]['required'] = !(actionDdl.input[ddlKey]['optional'])
      
      if actionDdl.input[ddlKey]['maxlength']
        validationRules[ddlKey]['maxlength'] = actionDdl.input[ddlKey]['maxlength']
          
      if actionDdl.input[ddlKey]['minlength']
        validationRules[ddlKey]['minlength'] = actionDdl.input[ddlKey]['maxlength']

      switch actionDdl.input[ddlKey].type
        when "string" then actionDdl.input[ddlKey]['isString'] = 1
        when "boolean" then actionDdl.input[ddlKey]['isBool'] = 1
    
    return {
      agent : agent,
      action : action,
      validationRules : validationRules
      meta : ddl['meta']
      actionDdl : actionDdl
    }
    
  requestDdl: (agent, action) ->
    that = @
    $.ajax({
      type: "GET"
      url: "/mcagents/" + agent
      success: (data) ->
        MCM.vent.trigger("action:receiveDdl", MCM.Routers.Action.prototype.transformDdl(data.ddl, agent, action))
        
      dataType: "json"
    });

  showAction: (agent, id) ->
    filterCollection = new MCM.Collections.ActionRequestFilter
    view = new MCM.Views.Layouts.Action {
      agent : agent,
      id : id,
      filterCollection : filterCollection,
      viewClass : MCM.Views.Layouts.ActionResults,
      cancelUrl : "/#/agent/"+agent
    }
    MCM.mainRegion.show(view);
    
    @requestDdl(agent, id)
});

MCM.addInitializer ->
  new MCM.Routers.Action()
