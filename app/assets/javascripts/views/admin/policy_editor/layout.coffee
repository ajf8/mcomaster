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
MCM.Views.Layouts.PolicyEditor = Backbone.Marionette.LayoutView.extend({
  template: HandlebarsTemplates['admin/policy_editor/layout']
  
  regions: {
    policiesEnabledRegion: "#policiesEnabled"
    agentPoliciesRegion: "#agentPolicies"
    allowUnconfiguredRegion: "#allowUnconfigured"
    defaultPolicyEnabledRegion: "#defaultPolicyEnabled"
  }

  createAgentPolicy: (e) ->
    view = new MCM.Views.NewAgentPolicy({ collection : this.collection })
    view.render()
    modalContainer = $("#modal")
    modalContainer.html(view.el)
    modalContainer.find(".modal").modal()
    e.preventDefault()

  events : {
    "click a.create-agent-policy-link" : "createAgentPolicy"
  }

  onShow: ->
    view = new MCM.Views.AgentPolicies({ collection : this.collection })
    @agentPoliciesRegion.show(view)

  showAppSettings: ->
    setting = MCM.app_settings.getSetting("policies_enabled", false)
    view = new MCM.Views.AppSettingCheckbox({ model : setting, description : "Enable action policies." })
    @policiesEnabledRegion.show(view)

    setting = MCM.app_settings.getSetting("defaults_enabled", false)
    view = new MCM.Views.AppSettingCheckbox({ model : setting, description : "Enable a default policy." })
    @defaultPolicyEnabledRegion.show(view)
    
    setting = MCM.app_settings.getSetting("allow_unconfigured", true)
    view = new MCM.Views.AppSettingCheckbox({ model : setting, description : "Allow requests for which the agent has no policies." })
    @allowUnconfiguredRegion.show(view)
})
