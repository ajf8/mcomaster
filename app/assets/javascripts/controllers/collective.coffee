MCM.Controllers.Collective = {
  showCollective: (id) ->
    collective = new MCM.Models.Collective({ id : id })
    collectiveView = new MCM.Views.Collective({ model : collective })
    
    collective.fetch()
    
    MCM.mainRegion.show(collectiveView)
}
