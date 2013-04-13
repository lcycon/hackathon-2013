ig = require('instagram-node').instagram()
async = require 'async'
_ = require 'underscore'
config = require '../config'


user = (req, res, next) ->
  userName = req.params.user
  getTopUsers 10, userName, config.ACCESS_TOKEN, (err, us) ->
    if err? then next err
    else
      json = toJson userName, us
      res.send json


toJson = (userName, friends) ->
  children = []
  for f in friends
    children.push name: f.key
  {
    name: userName
    children: children
  }

addUsersToHash = (memo, data, cb) ->
  userLikes = (user, cb) ->
    userName = user.username
    h = {}
    if memo[userName]?
      memo[userName] += 1
      cb null, memo
    else
      memo[userName] = 1
      cb null, memo

  async.each data.likes.data, userLikes, (err) ->
    if err? then cb err
    else cb null, memo


getTopUsers = (size, userName, accessToken, cb) ->
  ig.use access_token: accessToken
  ig.user_search userName, (err, users) ->
    if err? then cb err
    else
      userId = users[0].id
      ig.user_media_recent userId, {count: -1}, (err, medias) ->
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


exports.user = user
