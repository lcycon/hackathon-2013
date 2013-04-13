renderGraph = ->
  width = 720
  height = 720
  radius = Math.min(width, height) / 2

  color = d3.scale.category20()

  pie = d3.layout.pie()
    .sort(null)

  arc = d3.svg.arc()
    .innerRadius(radius - 100)
    .outerRadius(radius - 20)

  svg = d3.select("#content").append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("id", "mainsvg")
    .append("g")
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

  d3.json "/api/nestedTag/#{window.hashtag}", (data) ->
    childNode = window.document.getElementById 'oldmainsvg'
    if childNode?
      childNode.parentNode.removeChild childNode
    keys = (k for k,v of data)
    values = (v for k,v of data)
    groups = svg.selectAll("g")
      .data(pie(values))
    .enter().append('g').attr("class", "group").append("path")
      .attr("id", (d, i) -> "group" + i)
      .attr("fill", (d, i) -> color i)
      .attr("d", arc)

    clickhandle = (d, i) ->
      svg.select("#centertext").text("")
      childNode = window.document.getElementById 'mainsvg'
      childNode.setAttribute("id", "oldmainsvg")
      window.spinner.spin(document.getElementById 'content')
      window.hashtag = keys[i]
      renderGraph()

    svg.selectAll(".group")
      .on("click", clickhandle)

    svg.append("text")
      .attr("fill", "white")
      .attr("id", "centertext")
      .attr("text-anchor", "middle")
      .style("font-size", "60px")
      .text( (d, i) -> window.hashtag )

    groupText = svg.selectAll('.group').append("text")
      .attr("font-size", "1.5em")
      .attr("fill", "black")
      .attr("x", 6)
      .attr("dy", 40)
    
    groupText.append("textPath")
      .attr("xlink:href", (d, i) -> "#group" + i)
      .text( (d, i) -> keys[i] )

    window.spinner.stop()
    document.getElementById("spin").style.display = "none"
    document.getElementById("content").style.display = "block"

renderGraph()
