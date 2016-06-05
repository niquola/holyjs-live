plv8 = require('../node_modules/plpl/src/plv8')
assert = require('assert')
subject = require('../db/index')

json_call = (fn_name, params...) ->
  args = params.map((_, i)-> "$#{i+1}").join(',')
  res = plv8.execute("SELECT #{fn_name}(#{args})", params.map((x)-> JSON.stringify(x)))
  JSON.parse(res[0][fn_name])

describe "add slide", ()->
  res = subject.add_slide plv8,
    title: "Pg is awesome"
    code: "SELECT 'pg is awesome'"
  console.log(res)


