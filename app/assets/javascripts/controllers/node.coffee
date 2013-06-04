MCM.Controllers.Node = {
  myShowView: (view) ->
    MCM.mainRegion.show(view)
    
  getCommonView: (id) ->
    model = new MCM.Models.Node({id : id})
    view = new MCM.Views.Node({model : model})
    model.fetch()
    return view
      
  addActionBrowser: (id, view) ->
    agentsCollection = new MCM.Collections.NodeAgentFiltered(MCM.agents, view.model)
    applicationsCollection = new MCM.Collections.NodeApplicationFiltered(MCM.applications, view.model)
    view.runView = new MCM.Views.Layouts.Routes( nodemodel : view.model, agentsCollection : agentsCollection, applicationsCollection : applicationsCollection )

  showNodeFacts: (id) ->
    view = @getCommonView(id)
    @addActionBrowser(id, view)
    view.setTab("#nodeFactsTab")
    @myShowView(view)
  
  showNodeRun: (id) ->
    view = @getCommonView(id)
    @addActionBrowser(id, view)
    @myShowView(view)
    view.setTab("#nodeRunTab")
    
  showNodeAction: (id, agent, action) ->
    view = @getCommonView(id)
    filter = {
      identity : [ id ]
    }
    view.runView = new MCM.Views.Layouts.Action {
      agent : agent,
      id : action,
      cancelUrl : "/#/node/"+id
      nobread : true,
      resultsViewClass : MCM.Views.NodeActionResults,
      requestViewClass : MCM.Views.Layouts.NodeActionRequest,
      filter : filter
    }

    @myShowView(view)
    view.setTab("#nodeRunTab")
    MCM.Client.requestDdl(agent, action)
}
