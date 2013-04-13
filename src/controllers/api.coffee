ig = require '../helpers/instagram'

tag = (req, res, next) ->
  ig.getHashtag "food", (err, data) ->
    if err?
      throw err

    res.send data

exports.tag = tag
