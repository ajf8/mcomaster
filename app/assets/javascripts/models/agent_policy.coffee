MCM.Models.AgentPolicy = Backbone.Model.extend({
  url: "/dummy"

  onPolicyDestroy: ->
    if @policies.models.length == 0
      @destroy()

  sync: ->
    0

  constructor: (attributes, options) ->
    @policies = new MCM.Collections.Policies
    @listenTo @policies, "destroy", @onPolicyDestroy
    Backbone.Model.prototype.constructor.call(this, attributes, options)

  parse: (data) ->
    @policies.reset(data.policies)
    data.policies = undefined
    return data
})
