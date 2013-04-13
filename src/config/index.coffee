exports.setEnvironment = (env) ->
  console.log "set app environment: #{env}"
  switch(env)
    when "development"
      exports.DEBUG_LOG=true
      exports.DEBUG_WARN=true
      exports.DEBUG_ERROR=true
      exports.DEBUG_CLIENT=true
      exports.ACCESS_TOKEN="38855893.1fb234f.547bd6bab81148daa2bf713e35f25ee0"

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
      exports.ACCESS_TOKEN="38855893.1fb234f.547bd6bab81148daa2bf713e35f25ee0"
    else
      console.log "environment #{env} not found"
