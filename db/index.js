exports.add_slide = function(plv8, obj){
  res = plv8.execute(
    'INSERT INTO slides ' +
    '(title, code, position) values '+
    '($1, $2, (SELECT max(position) + 1 FROM slides LIMIT 1))'+
    ' RETURNING *',
    [obj.title, obj.code]
  );
  return JSON.stringify(res[0]);
};
exports.add_slide.plv8_signature = ['json','json'];

exports.update_slide = function(plv8, obj){
    plv8.execute('UPDATE slides SET title = $2, code = $3 WHERE id = $1', [obj.id, obj.title, obj.code]);
    return obj;
};
exports.update_slide.plv8_signature = ['json','json'];

exports.rm_slide = function(plv8, obj){
    plv8.execute('DELETE FROM slides where id = $1', [obj.id]);
    return obj;
};
exports.rm_slide.plv8_signature = ['json','json'];

exports.up_slide = function(plv8, obj){
    plv8.execute('UPDATE slides  SET position = position+1 where position = $1', [obj.position - 1]);
    plv8.execute('UPDATE slides  SET position = position-1 where id = $1', [obj.id]);
    return obj;
};
exports.up_slide.plv8_signature = ['json','json'];

exports.down_slide = function(plv8, obj){
    plv8.execute('UPDATE slides  SET position = position-1 where position = $1', [obj.position + 1]);
    plv8.execute('UPDATE slides  SET position = position+1 where id = $1', [obj.id]);
    return obj;
};
exports.down_slide.plv8_signature = ['json','json'];
