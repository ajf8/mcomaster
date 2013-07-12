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

# Decorate the application collection. If the application model
# has a "node_must_have" string it will be checked for in the
# nodes agents. It can be a function, in which case it should return true
# when provided the node model for it to display.

MCM.Collections.NodeApplicationFiltered = Backbone.Collection.extend({
  initialize: (models, options) ->
    @node = options.node
    @parent = options.parent
    
    @listenTo @node, "change", ->
      @filterByNode(@node)

    @listenTo @parent, "add", ->
      @filterByNode(@node)
      
    @filterByNode()
  
  filterByNode: (node) ->
    items = undefined
    
    if node
      items = []
      for i in @parent.models
        isValid = true
        if i.attributes.node_template == undefined
          isValid = false
        if typeof(i.attributes.node_must_have) == "string"
          isValid = $.inArray(i.attributes.node_must_have, node.attributes.agents) > -1
        else if typeof(i.attributes.node_must_have) == "function"
          isValid = i.attributes.node_must_have(node)
          
        if isValid
          items.push(i)
    else
      items = @parent.models
    
    # reset the filtered collection with the new items
    @reset items
})