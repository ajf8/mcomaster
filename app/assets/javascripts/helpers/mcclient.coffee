# An object with functions for interacting with API (rails controllers)

MCM.Client =
  # transform DDL, so it is easier to template using handlebars.js
  # and create the options for jquery.validation plugin
  # this is called from a successful requestDdl ajax call (below), then
  # the result sent out as a action:receiveDdl event on App.vent for
  # any view to receive
  transformDdl : (ddl, agent, action) ->
    actionDdl = ddl['actions'][action]
    
    if !actionDdl
      return
      
    validationRules = { }

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
        
    
    # when displaying result rows, this is used to make sure the columns
    # align properly (we don't have to rely on the same fields and order)
    columns = []
    outputs = actionDdl.output
    for own output of outputs
      columns.push(_.extend({key : output}, outputs[output]))

    return {
      agent : agent,
      action : action,
      validationRules : validationRules
      meta : ddl['meta']
      actionDdl : actionDdl
      columns : columns
    }

  # request a DDL, transform it with transformDdl, then send it out the event aggregator
  # as action:requestDdl
  requestDdl: (agent, action) ->
    that = @
    $.ajax({
      type: "GET"
      url: "/mcagents/" + agent
      success: (data) ->
        MCM.vent.trigger("action:receiveDdl", MCM.Client.transformDdl(data.ddl, agent, action))
        
      dataType: "json"
    })
  
  # gather the fields from the form and save them
  # into submission.args. convert booleans from strings
  # if the DDL says the field is a bool.
  
  submitActionForm: (submission) ->
    that = @
    submission.args = submission.args || {}
    _.each(submission.form.serializeArray(), (x) ->
      input_type = submission.ddl.input[x.name].type
      if input_type == "boolean"
        if x.value == "true"
          x.value = true
        else if x.value == "false"
          x.value = false
          
      submission.args[x.name] = x.value
    )
    
    @submitAction(submission)

  # submission object needs: args, action, agent
  # the server should immediately return as a "transaction ID" and then
  # background the execution. we use the txid a a handle to poll for new messages.
  # these are spooled over a redis queue on the server side.
  submitAction: (submission) ->
    that = @
    data = { 'filter' : submission.filter || {}, 'args' : submission.args || {} }
    $.ajax({
      type: "POST"
      url: "/execute/"+submission.agent+"/"+submission.action
      dataType: "json"
      data: JSON.stringify(data)
      success: (data) ->
        that.receiveTxn(data)
    })
  
  # helper for doing ajax requests on a transaction.
  # add a counter on the end of the URL to avoid caching
  # issues (some browsers seem to cache for less than a second with max-age:0?)
  txGet: (tx, options) ->
    if !tx.getCount
      tx.getCount = 0
      tx.msgCount = 0
      
    $.ajax(_.extend({
      url: "/mq/"+tx.txid+"/"+tx.getCount
      dataType: "json"
    }, options))
    
    tx.getCount++
  
  # TODO: make this a receive any kind of event? add infinite loop protection
  
  # each get can contain multiple messages
  # the top level of the response is an array of them
  receiveTxn: (tx) ->
    @txGet tx, {
      success: (rdata) =>
        for envelope in rdata
          # each message (envelope) has a "key" (the txid:messagenumber) and a "value" (the actual message)
          msg = envelope.value
          # use the presence of a key in the actual message to decide what it is
          # and fire the appropriate event
          if msg.begin
            MCM.vent.trigger("action:beginResults", tx, msg.begin)
          else if msg.node
            # use txid:messagenumber as a unique
            msg.node.id = envelope.key
            MCM.vent.trigger("action:receiveResult", tx, msg.node)
          else if msg.error
            MCM.vent.trigger("action:receiveError", tx, msg.error)
          else if msg.stats
            MCM.vent.trigger("action:receiveStats", tx, msg.stats)
          
          tx.msgCount++
          
          # server says this transaction is now closed, by replying with
          # an "end" key. eg. { end: 1 }
          # so stop polling
          if msg.end
            return
        
        # TODO: make configurable interval
        setTimeout =>
          @receiveTxn(tx)
        , 400
      
      # probably a 404, meaning that there's more
      # TODO: check status code, generate error event if not 404?
      error: (rdata) =>
        setTimeout =>
          @receiveTxn(tx)
        , 400
    }