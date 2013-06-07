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
MCM.Models.Node = Backbone.Model.extend({
  urlRoot:"/nodes"
  
  initialize: ->
    @factsCollection = new MCM.Collections.NodeFact
    
  # create a subcollection with facts so they can be displayed
  # in a collectionview
  parse: (data) ->
    facts = []
    for own key of data.facts
      facts.push(new MCM.Models.NodeFact(id : key, value : data.facts[key]))
      
    if @factsCollection
      @factsCollection.reset(facts)
    
    return data
});
