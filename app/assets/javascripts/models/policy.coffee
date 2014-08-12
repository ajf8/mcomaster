MCM.Models.Policy = Backbone.Model.extend({
  urlRoot: "/policies",

  initialize: ->
    memento = new Backbone.Memento(this);
    _.extend(this, memento);

})
