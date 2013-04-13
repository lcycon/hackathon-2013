width = 720
height = 720
outerRadius = Math.min(width, height) / 2 - 10
innerRadius = outerRadius - 24

formatPercent = d3.format(".1%")

arc = d3.svg.arc()
  .innerRadius(innerRadius)
  .outerRadius(outerRadius)

layout = d3.layout.chord()
  .padding(.10)
  .sortSubgroups(d3.descending)
  .sortChords(d3.ascending)

path = d3.svg.chord()
  .radius(innerRadius)

svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("id", "circle")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

svg.append("circle")
  .attr("r", outerRadius)

d3.json "/api/tag/#{window.hashtag}", (data) ->

  layout.matrix(data.matrix)

  mouseover = (d, i) ->
    console.log "Source index #{i}"
    console.log d
    chord.classed "fade", (p) ->
      p.source.index != i && p.target.index != i

  mouseout = (d, i) ->
    console.log "Source index #{i}"
    console.log d
    chord.classed "fade", (p) -> false

  group = svg.selectAll(".group")
      .data(layout.groups)
    .enter().append("g")
      .attr("class", "group")
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)

  group.append("title").text (d, i) ->
    data.data[i].name

  groupPath = group.append("path")
    .attr("id", (d, i) -> "group" + i)
    .attr("d", arc)
    .style("fill", (d,i) -> data.data[i].color)

  groupText = group.append("text")
    .attr("x", 6)
    .attr("dy", 15)

  groupText.append("textPath")
    .attr("xlink:href", (d,i) -> "#group" + i)
    .text((d, i) -> data.data[i].name)

  groupText.filter((d, i) -> groupPath[0][i].getTotalLength() / 2 - 25 < this.getComputedTextLength() )
    .remove()

  chord = svg.selectAll(".chord")
      .data(layout.chords)
    .enter().append("path")
      .attr("class", "chord")
      .style("fill", (d) -> data.data[d.source.index].color)
      .attr("d", path)
