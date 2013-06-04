MCM.Controllers.Action = {
  showAction: (agent, id) ->
    filterCollection = new MCM.Collections.ActionRequestFilter
    view = new MCM.Views.Layouts.Action {
      agent : agent,
      id : id,
      filterCollection : filterCollection,
      resultsViewClass : MCM.Views.Layouts.ActionResults,
      requestViewClass : MCM.Views.Layouts.ActionRequest,
      cancelUrl : "/#/agent/"+agent
    }
    MCM.mainRegion.show(view);
    
    MCM.Client.requestDdl(agent, id)
}
