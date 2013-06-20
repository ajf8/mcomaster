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

MCM.Collections.Paginator = (original, settings) ->
  filtered = new Backbone.Collection()
  filtered.perPage = settings && settings.perPage || 20 
  filtered.page = 0
  
  # allow this object to have it's own events
  filtered._callbacks = {}
  
  filtered.getPages = ->
    return Math.ceil(original.length / filtered.perPage)
  
  filtered.fullLength = ->
    return original.length
    
  # call 'where' on the original function so that
  # filtering will happen from the complete collection
  filtered.setPage = (page) ->
    items = undefined
    
    # call 'where' if we have criteria
    # or just get all the models if we don't
    if settings.perPage
      items = []
      i = 0
      if page > 0
        i = filtered.perPage * page
      end = i + filtered.perPage
      while i < end and i < original.models.length - 1
        items.push(original.models[i])
        i++
    else
      items = original.models
    
    filtered.page = page
    
    # reset the filtered collection with the new items
    filtered.reset items
    
    filtered.trigger("resultsPaginator:changePage", filtered.page)
    
  # when the original collection is reset,
  # the filtered collection will re-filter itself
  # and end up with the new filtered result set
  original.on "add", (model) ->
    if filtered.length < filtered.perPage
      filtered.add(model)
    else if filtered.page == 0 and original.length == filtered.perPage+1
      filtered.trigger("resultsPaginator:needsControls")
    else if original.length % filtered.perPage == 0 && original.length != 0
      filtered.trigger("resultsPaginator:newPage", (original.length/filtered.perPage)-1)
  
  filtered