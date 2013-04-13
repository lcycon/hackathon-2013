controllers = require './controllers'

module.exports = (app) ->

  app.get '/', (req, res, next) ->
    controllers.example.index req, res, next

  app.get '/graph/chord/:tag', controllers.example.chord

  app.get '/graph/tree/:user', controllers.example.tree

  app.get '/graph/:id', controllers.example.graph

  app.get '/api/tag/:tag', (req, res, next) ->
    controllers.api.tag req, res, next

  app.get '/api/user/:user', controllers.user.user
