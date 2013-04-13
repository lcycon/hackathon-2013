ig = require '../helpers/instagram'
async = require 'async'

tag = (req, res, next) ->

  hashtag = req.params.tag

  ig.getHashtag hashtag, (err, data) ->
    if err?
      throw err

    newData = {}
    newData[hashtag] = data

    keys = (k for k, v of data)
    async.map keys, ig.getHashtag, (error, results) ->
      finalKeys = []
      for datum, index in results then do (datum, index) ->
        finalKeys.push keys[index]
        newData[keys[index]] = datum

      secondDegreeCounts = []
      for key, vals of newData then do (vals) ->
        for tag, count of vals then do (tag, count) ->
          secondDegreeCounts.push {tag: tag, count: count}
          finalKeys.push tag

      secondDegreeCounts.sort (a,b) ->
        b.count - a.count

      newSecondDegree = []
      for val in secondDegreeCounts then do (val) ->
        unless val in newSecondDegree
          newSecondDegree.push val

      newSecondDegree = newSecondDegree.map (d) -> d.tag
      newFinalKeys = [hashtag]
      for val in finalKeys then do (val) ->
        unless val in newSecondDegree.slice(0,10) || val in keys || val is hashtag
          return
        unless val in newFinalKeys
          newFinalKeys.push val

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


exports.tag = tag
