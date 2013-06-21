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

# This collection decorates the agents collection, and filters it based on a node collection.

MCM.Collections.NodeAgentFiltered = Backbone.Collection.extend({
  # call 'where' on the parent function so that
  # filtering will happen from the complete collection
  filterByNode: (node) ->
    items = undefined
    
    # call 'where' if we have criteria
    # or just get all the models if we don't
    if node
      items = []
      for i in @parent.models
        if $.inArray(i.attributes.id, node.attributes.agents) > -1
          items.push(i)
    else
      items = @parent.models
    
    # store current criteria
    @currentNode = node
    
    # reset the filtered collection with the new items
    @reset items

  # when the parent collection is reset,
  # the filtered collection will re-filter itself
  # and end up with the new filtered result set
  initialize: (models, options) ->
    @node = options.node
    @parent = options.parent
    
    @listenTo @node, "change", ->
      @filterByNode(@node)
  
    @listenTo @parent, "add", =>
      @filterByNode(@currentNode)
    
    @filterByNode()
})