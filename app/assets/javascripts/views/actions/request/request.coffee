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
MCM.Views.ActionRequest = Backbone.Marionette.ItemView.extend({
  template: HandlebarsTemplates['actions/request/request']
  
  setDdl: (ddl) ->
    @ddl = ddl.actionDdl
    @validationRules = ddl.validationRules
    @validationMessages = ddl.validationMessages
    @render()
  
  templateHelpers: ->
    ctx = {
      id : @options.id,
      agent : @options.agent,
      cancelUrl : @options.cancelUrl,
      ddl : @ddl,
      isFromLog : @options.isFromLog
    }
    
    if @ddl && _.size(@ddl.input) > 0
      ctx.hasInputs = true
      
    return ctx
      
  initialize: ->
    @listenTo MCM.vent, 'action:receiveDdl', (ddl) =>
      @setDdl(ddl)
      if @ddl
        $("#actionForm").validate({
          rules : @validationRules
          onkeyup : (element) ->
            this.element(element)
        })
    
  onShow: ->
    $("#actionForm").fadeIn(200)
})
