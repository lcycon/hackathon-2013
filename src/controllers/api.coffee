ig = require '../helpers/instagram'
async = require 'async'

tag = (req, res, next) ->

  hashtag = req.params.tag

  # Get top level hashtag relations
  ig.getHashtag hashtag, (err, data) ->
    if err?
      throw err

    # Prepare for the storm
    newData = {}
    newData[hashtag] = data

    # Just the keys of level one
    keys = (k for k, v of data)

    # Get associated hashtags on ALL OF THIS
    async.map keys, ig.getHashtag, (error, results) ->
      # Get our raw list of keys
      finalKeys = []
      for datum, index in results then do (datum, index) ->
        finalKeys.push keys[index]
        newData[keys[index]] = datum

      # Get a list of second degree keys to work on
      secondDegreeCounts = []
      for key, vals of newData then do (vals) ->
        for tag, count of vals then do (tag, count) ->
          secondDegreeCounts.push {tag: tag, count: count}
          finalKeys.push tag

      # Sort it
      secondDegreeCounts.sort (a,b) ->
        b.count - a.count

      # De-dupe it
      newSecondDegree = []
      for val in secondDegreeCounts then do (val) ->
        unless val in newSecondDegree
          newSecondDegree.push val

      # Map to just tag names
      newSecondDegree = newSecondDegree.map (d) -> d.tag

      # Our keys that we want to graph
      newFinalKeys = [hashtag]
      for val in finalKeys then do (val) ->
        # If they are small and useless, forget them
        unless val in newSecondDegree.slice(0,10) || val in keys || val is hashtag
          return
        # If its a dupe, skip
        unless val in newFinalKeys
          newFinalKeys.push val

      # Final data
      #
      # Build matrix of relationships
      responseData = []
      for key, index in newFinalKeys then do (key, index) ->
        for innerKey, innerIndex in newFinalKeys then do (innerKey, innerIndex) ->

          responseData[index] = [] unless responseData[index]?
          responseData[innerIndex] = [] unless responseData[innerIndex]?

          unless newData[key]?
            responseData[index][innerIndex] = 0 unless responseData[index][innerIndex]?
            responseData[innerIndex][index] = 0 unless responseData[innerIndex][index]?
            return

          count = newData[key][innerKey]

          if count?
            responseData[index][innerIndex] = count unless responseData[index][innerIndex]?
            responseData[innerIndex][index] = count unless responseData[innerIndex][index]?
          else
            responseData[index][innerIndex] = 0 unless responseData[index][innerIndex]?
            responseData[innerIndex][index] = 0 unless responseData[innerIndex][index]?


      names = newFinalKeys.map (key) ->
        if key is hashtag
          color = "#FF3333"
        else if key in keys
          color = "#FFD700"
        else
          color = "#AAAAAA"

        {name: key, color: color}

      res.send {
        matrix: responseData
        data: names
      }

nestedTags = (req, res, next) ->

  hashtag = req.params.tag

  ig.getHashtag hashtag, (err, data) ->

    res.send data

exports.tag = tag
exports.nestedTags = nestedTags
