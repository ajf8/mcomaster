MCM.ResultHelpers = {}

MCM.ResultHelpers.newRow = (model, key) ->
  v = model.attributes.body.data[key]
  display_value = undefined
  if v == undefined or v == null
    display_value = "(null)"
  else
    display_value = v.toString()
    
  return {
    kee : key,
    val : display_value
    isComplex : $.isArray(v) or $.isPlainObject(v)
  }