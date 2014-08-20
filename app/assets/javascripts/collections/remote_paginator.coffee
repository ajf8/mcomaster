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

MCM.Collections.RemotePaginator = Backbone.Collection.extend({
  url: ->
    return @unpaginatedUrl() + "/page/" + (@page + 1)

  initialize: (models, options) ->
    options = options || {}
    @perPage = options.perPage || 50
    @page = 0

  getPages: ->
    return Math.ceil(@x_total / @perPage)

  fullLength: ->
    return @x_total

  setPage: (page) ->
    @page = page
    that = @
    @fetch
      success: ->
        that.trigger("paginator:changePage", @page)
})
