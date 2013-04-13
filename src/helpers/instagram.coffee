{EventEmitter} = require 'events'


class TagPhotoEmitter extends EventEmitter
  ig: require('instagram-node').instagram()

  count: 100

  constructor: (tag) ->
    @ig.use {access_token: "38855893.1fb234f.547bd6bab81148daa2bf713e35f25ee0"}
    @tag = tag

  run: =>
    @ig.tag_media_recent @tag, @parseData

  parseData: (err, res, page, limit) =>

    if @count <= 0
      @emit 'done'
      return

    if err?
      throw err

    if res?
      for photo in res then do (photo) =>
        @emit 'photo', photo

    if page.next
      if res?
        deduction = res.length
      else
        deduction = 0

      @count = @count - deduction
      page.next @parseData
    else
      @emit 'done'


getHashtag = (hashtag, pcb) ->

  tags = {}

  photos = new TagPhotoEmitter hashtag

  photos.on 'photo', (photo) ->
    console.log "Got a photo!"
    for tag in photo.tags then do (tag) ->
      if tag is hashtag then return
      if tags[tag]?
        tags[tag]++
      else
        tags[tag] = 1

  photos.on 'done', ->
    console.log "Done"
    arr = []
    arr.push {tag: t, count: c} for t,c of tags
    arr.sort (a, b) ->
      b.count - a.count
    pcb null, arr.slice(0,8)

  photos.run()

exports.getHashtag = getHashtag
