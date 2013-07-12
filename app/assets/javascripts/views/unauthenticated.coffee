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
MCM.Views.Layouts.Unauthenticated = Backbone.Marionette.Layout.extend(
  template: HandlebarsTemplates["unauthenticated"]
  
  regions:
    tabContent: "#tab-content"

  views: {}
  events:
    "click ul.nav-tabs li a": "switchViews"

  onShow: ->
    @views.login = MCM.Views.Unauthenticated.Login
    @views.signup = MCM.Views.Unauthenticated.Signup
    @views.retrievePassword = MCM.Views.Unauthenticated.RetrievePassword
    @tabContent.show new @views.login

  switchViews: (e) ->
    e.preventDefault()
    @tabContent.show new @views[$(e.target).data("content")]
)
