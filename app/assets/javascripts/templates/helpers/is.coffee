isArray = (value) ->
  Object::toString.call(value) is "[object Array]"

ExpressionRegistry = ->
  @expressions = []
  return

ExpressionRegistry::add = (operator, method) ->
  @expressions[operator] = method
  return

ExpressionRegistry::call = (operator, left, right) ->
  throw new Error("Unknown operator \"" + operator + "\"")  unless @expressions.hasOwnProperty(operator)
  @expressions[operator] left, right

eR = new ExpressionRegistry
eR.add "not", (left, right) ->
  left isnt right

eR.add ">", (left, right) ->
  left > right

eR.add "<", (left, right) ->
  left < right

eR.add ">=", (left, right) ->
  left >= right

eR.add "<=", (left, right) ->
  left <= right

eR.add "===", (left, right) ->
  left is right

eR.add "!==", (left, right) ->
  left isnt right

eR.add "in", (left, right) ->
  right = right.split(",")  unless isArray(right)
  right.indexOf(left) isnt -1

isHelper = ->
  args = arguments
  left = args[0]
  operator = args[1]
  right = args[2]
  options = args[3]
  if args.length is 2
    options = args[1]
    return options.fn(this)  if left
    return options.inverse(this)
  if args.length is 3
    right = args[1]
    options = args[2]
    return options.fn(this)  if left is right
    return options.inverse(this)
  return options.fn(this)  if eR.call(operator, left, right)
  options.inverse this

Handlebars.registerHelper "is", isHelper