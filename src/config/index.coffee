exports.setEnvironment = (env) ->
  console.log "set app environment: #{env}"
  switch(env)
    when "development"
      exports.DEBUG_LOG=true
      exports.DEBUG_WARN=true
      exports.DEBUG_ERROR=true
      exports.DEBUG_CLIENT=true
      exports.ACCESS_TOKEN="30695083.1fb234f.25beb64530ac49c991a5de62d5b5713f"

    when "testing"
      exports.DEBUG_LOG=true
      exports.DEBUG_WARN=true
      exports.DEBUG_ERROR=true
      exports.DEBUG_CLIENT=true

    when "production"
      exports.DEBUG_LOG=false
      exports.DEBUG_WARN=false
      exports.DEBUG_ERROR=true
      exports.DEBUG_CLIENT=false
      exports.ACCESS_TOKEN="30695083.1fb234f.25beb64530ac49c991a5de62d5b5713f"
    else
      console.log "environment #{env} not found"
