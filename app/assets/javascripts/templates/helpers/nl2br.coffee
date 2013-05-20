Handlebars.registerHelper "nl2br", (text) ->
  text = Handlebars.Utils.escapeExpression(text)
  nl2br = (text + "").replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1" + "<br>" + "$2")
  new Handlebars.SafeString(nl2br)
