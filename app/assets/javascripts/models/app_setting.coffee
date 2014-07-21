MCM.Models.AppSetting = Backbone.Model.extend(
  urlRoot: "/app_settings",
  
  getSettingValue: ->
    return @attributes.set_val
)
