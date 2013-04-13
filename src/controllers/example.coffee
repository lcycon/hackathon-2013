index = (req, res) ->
  res.render 'index',
    title: 'Coffee Express'

graph = (req, res, next) ->
  res.render 'graphs/' + req.params.id

chord = (req, res, next) ->
  res.render 'graphs/chord',
    hashtag: req.params.tag

tree = (req, res, next) ->
  res.render 'graphs/tree',
    user: req.params.user

exports.index = index
exports.graph = graph
exports.chord = chord
exports.tree = tree
