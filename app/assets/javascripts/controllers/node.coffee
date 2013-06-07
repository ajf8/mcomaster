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

# A bit more complicated than I'd like, to choose the contents of the
# first tab depending on the URL state.  
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
