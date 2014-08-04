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
MCM.Views.NewAgentPolicy = Backbone.Marionette.LayoutView.extend({
  template: HandlebarsTemplates['admin/policy_editor/new_agent_policy']

  regions : {
    agentDropdownRegion : ".agent-dropdown-container"
    actionDropdownRegion : ".action-dropdown-container"
    usersDropdownRegion : ".users-dropdown-container"
  }

  initialize: (options) ->
    @collection = options.collection
    @model = new MCM.Models.Policy
    @model.set('policy', 'allow')

  events : {
    "click .agent-dropdown-container ul.dropdown-menu a" : "agentSelected"
    "click .action-dropdown-container ul.dropdown-menu a" : "actionSelected"
    "click .policy-dropdown-container ul.dropdown-menu a" : "policySelected"
    "click .users-dropdown-container ul.dropdown-menu a" : "userSelected"
    "click .policy-submit-button" : "submitPolicy"
    "click .policy-cancel-button" : "cancelPolicy"
  }

  cancelPolicy: (e) ->
    $(@el).find(".modal").modal("hide")
    e.preventDefault()

  submitPolicy: (e) ->
    model = @model
    collection = @collection

    model.save model.attributes, 
      success: ->
        agentPolicy = collection.get(model.attributes.agent)

        if agentPolicy
          agentPolicy.policies.add(model)
        else
          agentPolicy = new MCM.Models.AgentPolicy({ id : model.attributes.agent })
          agentPolicy.policies.add(model)

        collection.add(agentPolicy)

    $(@el).find(".modal").modal("hide")
    e.preventDefault()

  setDropdownValue: (selector, value) ->
    selectionEl = $(@el).find(selector + " .selection")
    selectionEl.html(value)
    if @model.attributes.agent and @model.attributes.action_name and @model.attributes.callerid
      $(@el).find(".btn-primary").removeAttr("disabled")

  userSelected: (e) ->
    user = $(e.target).data("id")
    @model.set('callerid', user)
    @setDropdownValue(".users-dropdown-container", user)
    e.preventDefault()

  policySelected: (e) ->
    policy = $(e.target).data("id")
    @model.set('policy', policy)
    @setDropdownValue(".policy-dropdown-container", policy)
    e.preventDefault()

  actionSelected: (e) ->
    @selectedAction = $(e.target).data("id")
    @model.set('action_name', @selectedAction)
    @setDropdownValue(".action-dropdown-container", @selectedAction)
    e.preventDefault()

  agentSelected: (e) ->
    @selectedAgent = $(e.target).data("id")
    @model.set('agent', @selectedAgent)
    @setDropdownValue(".agent-dropdown-container", @selectedAgent)
    agentModel = MCM.agents.get(@selectedAgent)

    actionCollection = new MCM.Collections.Transient
    actionCollection.add(new MCM.Models.Transient({ id : "*" }))

    for action_name, action of agentModel.attributes.ddl.actions
      actionData = _.extend({ id : action_name }, action)
      actionModel = new MCM.Models.Transient(actionData)
      actionCollection.add(actionModel)

    @actionDropdownRegion.show(new MCM.Views.ActionDropdown({ collection : actionCollection }))
    e.preventDefault()

  onRender: ->
    view = new MCM.Views.AgentDropdown({ collection : MCM.agents })
    @agentDropdownRegion.show(view)

#    policyChoices = new MCM.Collections.Transient
#    policyChoices.add(new MCM.Models.Transient({ id : "allow" }))
#    policyChoices.add(new MCM.Models.Transient({ id : "deny" }))
#    view = new MCM.Views.PolicyDropdown({ collection : policyChoices })
#    @policyDropdownRegion.show(view)

    view = new MCM.Views.UserDropdown({ collection : MCM.users })
    @usersDropdownRegion.show(view)
})
