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

# This collection decorates the results collection

MCM.Collections.LocalPaginator = Backbone.Collection.extend({
  initialize: (models, options) ->
    @original = options.original
    @perPage = options.perPage || 50
    @page = 0

    @original.on "add", (model) =>
      if @length < @perPage
        @add(model)
      else if @page == 0 and @original.length == @perPage+1
        @trigger("paginator:needsControls")
      else if @original.length % @perPage == 0 && @original.length != 0
        @trigger("paginator:newPage", (@original.length/@perPage)-1)

  getPages: ->
    return Math.ceil(@original.length / @perPage)

  fullLength: ->
    return @original.length

  setPage: (page) ->
    items = undefined

    if @perPage
      items = []
      i = 0
      if page > 0
        i = @perPage * page
      end = i + @perPage
      while i < end and i < @original.models.length - 1
        items.push(@original.models[i])
        i++
    else
      items = @original.models

    @page = page

    @reset items

    @trigger("paginator:changePage", @page)
})
