express = require('express')
app = express()
plv8 = require('./node_modules/plpl/src/plv8')
bodyParser = require('body-parser')


json_call = (fn_name, params) ->
  args = params.map((_, i)-> "$#{i+1}").join(',')
  res = plv8.execute("SELECT #{fn_name}(#{args})", params.map((x)-> JSON.stringify(x)))
  JSON.parse(res[0][fn_name])

app.use (req, res, next)->
  res.header("Access-Control-Allow-Origin", "*")
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
  next()

app.use(bodyParser.json())

call_fn = (fn, args, res)->
  try
    data = json_call(fn, args)
    res.send(JSON.stringify(data))
    res.end()
  catch e
    res.status(500)
    res.send(e.toString())
    res.end()

app.post '/fn/:fn', (req, res)->

  args = if req.body
    if Array.isArray(req.body)
      req.body
    else [req.body]
  else
    []

  fn = req.params.fn
  call_fn(fn, args, res)

app.get '/fn/:fn', (req, res)->
  args = [req.query]
  fn = req.params.fn
  call_fn(fn, args, res)

app.get '/sql/*', (req, res)->
  sql = decodeURI(req.path).replace(/\/sql\//,'')
  try
    data = plv8.execute(sql)
    res.send(JSON.stringify(data))
    res.end()
  catch e
    res.status(500)
    res.send(e.toString())
    res.end()

app.post '/sql', (req, res)->
  sql = req.body.query
  console.log(req.body)
  try
    data = plv8.execute(sql)
    res.send(JSON.stringify(data))
    res.end()
  catch e
    res.status(500)
    res.send(e.toString())
    res.end()

app.listen 8888, ()->
  console.log('Example app listening on port 8000!')
