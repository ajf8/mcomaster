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
MCM.Views.PoliciesTableItem = Backbone.Marionette.LayoutView.extend({
  template: HandlebarsTemplates['admin/policy_editor/policies_table_item']
  tagName: "tr"

  regions: {
    "usersDropdownRegion" : ".user-dropdown-container"
    "actionDropdownRegion" : ".action-dropdown-container"
    "policyDropdownRegion" : ".policy-dropdown-container"
  }

  events : {
    "keyup .action-input-container input" : "actionChanged"
  }

  initialize: (options) ->
    @isDefault = options.isDefault

  templateHelpers: ->
    return {
      isDefault : @isDefault
    }

  userChanged: (value) ->
    @model.save({ callerid : value })

  actionChanged: (value) ->
    @model.save({ action_name : value })

  policyChanged: (value) ->
    @model.save({ policy : value })

  onRender: ->
    view = new MCM.Views.AdminDropdown({ collection : MCM.users, idColumn : "name", displayColumn : "name", initialValue : @model.attributes.callerid, extraItem : "*" })
    @listenTo(view, "changed", @userChanged)
    @usersDropdownRegion.show(view)

    agentModel = MCM.agents.get(@model.attributes.agent)

    if agentModel
      actionCollection = agentModel.getActionCollection()
    else
      actionCollection = new MCM.Collections.Transient

    unless @isDefault
      view = new MCM.Views.AdminDropdown({ collection : actionCollection, initialValue : @model.attributes.action_name, extraItem : "*" })
      @listenTo(view, "changed", @actionChanged)
      @actionDropdownRegion.show(view)

    policyCollection = new MCM.Collections.Transient
    policyCollection.add(new MCM.Models.Transient({ id : "allow" }))
    policyCollection.add(new MCM.Models.Transient({ id : "deny" }))
    view  = new MCM.Views.AdminDropdown({ collection : policyCollection, initialValue : @model.attributes.policy })
    @listenTo(view, "changed", @policyChanged)
    @policyDropdownRegion.show(view)
})
