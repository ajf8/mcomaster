MCM.Models.AgentPolicy = Backbone.Model.extend({
  url: "/dummy"
  parse: (data) ->
    this.policies = new MCM.Collections.Policies
    this.policies.reset(data.policies)
    data.policies = undefined
    return data
})
