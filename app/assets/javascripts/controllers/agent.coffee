MCM.Controllers.Agent = {
  showAgent: (id) ->
    node = new MCM.Models.Agent({ id : id })
    agentsView = new MCM.Views.Agent({ model : node })
    
    node.fetch()
    
    MCM.mainRegion.show(agentsView)
}