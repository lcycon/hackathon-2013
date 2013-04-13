path = require 'path'

express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
jade = require 'jade'

app = express()
app.port = process.env.PORT or process.env.VMC_APP_PORT or 3000

# Get out config
config = require './config'
app.configure 'production', 'development', 'testing', ->
  # Initialize the config
  config.setEnvironment app.settings.env

# Use Rails-esque asset pipeline
app.use assets()
# Automagic parsing of JSON post body, et cetera
app.use express.bodyParser()
app.use express.static process.cwd() + '/public'
# Jade, since raw HTML is hard
app.set 'view engine', 'jade'

# Set up our routes
routes = require './routes'
routes app

module.exports = app
