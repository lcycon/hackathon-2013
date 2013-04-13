ig = require('instagram-node').instagram()
async = require 'async'
_ = require 'underscore'
config = require '../config'


user = (req, res, next) ->
  ig.authorize_url req.query.code, config.RES_URI, (err, response) ->
    if err? then next err
    else
      getTopUsers 10, result.user.username, result.access_token, (err, us) ->
        if err? then next err
        else
          console.log us


addUsersToHash = (memo, data, cb) ->
  userLikes = (user, cb) ->
    h = {}
    if memo.user?
      memo.user += 1
      cb null, memo
    else
      memo.user = 1
      cb null, memo

  async.each data.likes.data, userLikes, (err) ->
    if err? then cb err
    else cb null, memo


getTopUsers = (size, userName, accessToken, cb) ->
  ig.use access_token: accessToken
  ig.user_media_recent @user, count: -1, (err, medias) ->
    if err? then cb err
    else
      users = async.reduce medias, {}, addUsersToHash, (err, usrs) ->
        if err? then cb err
        else cb null, topUsers size, usrs


topUsers = (size, users) ->
  list = []
  if size is 0
    list
  else
    for k, v of users
      if list.length is 0
        list.push {key: k, val: v}
      else if list.length < size
        list.push {key: k, val: v}
        list.sort (a, b) -> b.val - a.val
      else
        list.pop()
        list.push {key: k, val: v}
        list.sort (a, b) -> b.val - a.val

    list.slice 0, size

