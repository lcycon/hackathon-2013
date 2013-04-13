# Error handling middleware

logErrors = (err, req, res, next) ->
  console.error 'Error: ' + err.message
  console.error err.stack
  if err.additionalData?
    for d in err.additionalData then do (d) ->
      console.error d
  unless err.onlyLog
    next err

clientErrorHandler = (err, req, res, next) ->
  if req.xhr
    res.send 500, error: "We're all going to die!"
  else
    next err


errorHandler = (err, req, res, next) ->
  res.status 500
  res.render 'error', message: 'Something blew up!'


respond404 = (req, res, next) ->
  res.status 404

  if req.accepts 'html'
    res.render '404', url: req.url
  else if req.accepts 'json'
    res.send error: 'Not found'
  else
    res.type('type').send 'Not found'


exports.log = logErrors
exports.clientHandler = clientErrorHandler
exports.finalHandler = errorHandler
exports.respond404 = respond404
