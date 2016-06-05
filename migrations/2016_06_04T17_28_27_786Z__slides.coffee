exports.up = (plv8)->
  plv8.execute """
   CREATE TABLE slides (id serial, title text, code text)
  """
