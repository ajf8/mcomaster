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

MCM.Collections.NodeAgentFiltered = (original, nodemodel) ->
  filtered = new original.constructor()
  
  # allow this object to have it's own events
  filtered._callbacks = {}
  
  original.listenTo nodemodel, "change", ->
    filtered.filterByNode(nodemodel)
  
  # call 'where' on the original function so that
  # filtering will happen from the complete collection
  filtered.filterByNode = (node) ->
    items = undefined
    
    # call 'where' if we have criteria
    # or just get all the models if we don't
    if node
      items = []
      for i in original.models
        if $.inArray(i.attributes.id, node.attributes.agents) > -1
          items.push(i)
    else
      items = original.models
    
    # store current criteria
    filtered._currentNode = node
    
    # reset the filtered collection with the new items
    filtered.reset items

  
  # when the original collection is reset,
  # the filtered collection will re-filter itself
  # and end up with the new filtered result set
  original.on "add", ->
    filtered.filterByNode filtered._currentNode
  
  filtered.filterByNode()
  
  filtered