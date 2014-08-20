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
MCM.Controllers.Log = {
  index: ->
    collection = new MCM.Collections.Actlog
    collection.fetch()

    view = new MCM.Views.LogLayout(collection : collection)
    MCM.mainRegion.show(view)

  replay: (agent, action, id) ->
    filterCollection = new MCM.Collections.Filter
    view = new MCM.Views.Layouts.Action {
      agent : agent,
      id : action,
      nobread : true,
      filterCollection : filterCollection,
      resultsViewClass : MCM.Views.Layouts.ActionResults,
      requestViewClass : MCM.Views.Layouts.LogActionRequest,
      cancelUrl : "/#/log/"
    }
    MCM.mainRegion.show(view)

    MCM.Client.requestDdl(agent, action).done ->
      MCM.Client.logReplay(id).done (data) ->
        view.request.setInputs(data.args)
        view.request.filterView.setFiltersFromReplay(data.filters)

  show: (id) ->
    collection = new MCM.Collections.Actlog
    model = new MCM.Models.Actlog({ id : id })
    view = new MCM.Views.Layouts.LogAction({ model : model, collection : collection })
    MCM.mainRegion.show(view)
    model.fetch()
    collection.fetch()

  showResponse: (aid, id) ->
    model = new MCM.Models.Responselog(id : id)
    view = new MCM.Views.Layouts.LogResponse({ model : model })
    model.fetch()
    MCM.mainRegion.show(view)
}
