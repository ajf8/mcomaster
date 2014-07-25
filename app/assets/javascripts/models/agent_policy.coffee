MCM.Models.AgentPolicy = Backbone.Model.extend({
  url: "/dummy"

  onPolicyDestroy: ->
    if this.policies.models.length == 0
      this.destroy()

  sync: ->
    0

  parse: (data) ->
    this.policies = new MCM.Collections.Policies
    this.listenTo this.policies, "destroy", this.onPolicyDestroy
    this.policies.reset(data.policies)
    data.policies = undefined
    return data
})
