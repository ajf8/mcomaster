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
MCM.Views.LoggedInBar = Backbone.Marionette.ItemView.extend({
  template: HandlebarsTemplates['logged_in_bar']
  
  onShow: ->
    $("#search").closest("form").submit (event) ->
      event.preventDefault()
    
    # setup bootstrap typeahead JS on search input.
    $("#search").typeahead({
      minLength: 2
      updater: (item) ->
        sp = item.split(":")
        window.location = "/#/"+sp[0]+"/"+sp[1]
        return item
      
      # do ajax (form) request to get results
      # set the type returned as a property on the result
      # string, which is used in the template for icon.
      source: (query,process) ->
        $.post '/search', { q: query, limit: 8 }, (data) ->
          r = []
          for k,v of data
            for x in v
              s = new String(k+":"+x)
              s.searchResultType = k
              r.push(s)
          process(r)

      highlighter: (data) ->
        compiled = HandlebarsTemplates['search_item']({ id : data, type : data.searchResultType })
        return compiled
    })
})
