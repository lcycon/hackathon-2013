controllers = require './controllers'

module.exports = (app) ->

  app.get '/', (req, res, next) ->
    controllers.example.index req, res, next

  app.get '/graph/chord/:tag', controllers.example.chord

  app.get '/graph/:id', controllers.example.graph

  app.get '/api/tag/:tag', (req, res, next) ->
    controllers.api.tag req, res, next
