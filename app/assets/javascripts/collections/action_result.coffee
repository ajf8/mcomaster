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
MCM.Collections.ActionResult = Backbone.Collection.extend({
  model: MCM.Models.ActionResult
  
  # create a result collection with the transaction object
  # (returned by the server, see mcclient.coffee)
  # then listen for any results to that txid
  initialize: (models, options) ->
    @tx = options.tx
    
    @listenTo MCM.vent, "action:receiveResult", (tx, msg) =>
      if tx.txid == @tx.txid
        msg.idx = @length + 1
        @add(new MCM.Models.ActionResult(msg))
        # for pagination testing - multiplies results
        #baseId = msg.id
        #i = 0
        #while i < 500
        #  msg.id = baseId + i
        #  msg.idx = @length + 1
        #  @add(new MCM.Models.ActionResult(msg))
        #  i++
})
