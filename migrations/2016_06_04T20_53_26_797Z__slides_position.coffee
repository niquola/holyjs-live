exports.up = (plv8)->
  plv8.execute """
   ALTER TABLE slides ADD COLUMN position integer;
  """

  plv8.execute """
    UPDATE slides SET position = id
  """
