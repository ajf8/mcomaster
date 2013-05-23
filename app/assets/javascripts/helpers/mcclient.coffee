MCM.Client = 
  transformDdl : (ddl, agent, action) ->
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
        MCM.vent.trigger("action:receiveDdl", MCM.Client.transformDdl(data.ddl, agent, action))
        
      dataType: "json"
    });
    
  submitActionForm: (submission) ->
    that = @
    submission.formData = submission.args || {}
    submission.formData.args = {}
    _.each(submission.form.serializeArray(), (x) ->
      input_type = submission.ddl.input[x.name].type
      if input_type == "boolean"
        if x.value == "true"
          x.value = true
        else if x.value == "false"
          x.value = false
          
      submission.formData.args[x.name] = x.value
    )
    
    @submitAction(submission)

  submitAction: (submission) ->
    that = @
    $.ajax({
      type: "POST"
      url: "/execute/"+submission.agent+"/"+submission.action 
      dataType: "json"
      data: JSON.stringify(submission.formData)
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