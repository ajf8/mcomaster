MCM.Models.AppSetting = Backbone.Model.extend(
  urlRoot: "/app_settings",

  initialize: ->
    memento = new Backbone.Memento(this);
    _.extend(this, memento);

  getSettingValue: ->
    return @attributes.set_val
)
