width = 960
height = 2200
centered = null


cluster = d3.layout.cluster()
  .size [height, width - 160]


diagonal = d3.svg.diagonal()
  .projection (d) -> [d.y, d.x]


svg = d3.select('body').append('svg')
  .attr('width', width)
  .attr('height', height)
  .append('g')
  .attr('transform', 'translate(40,0)')


path = d3.geo.path()


g = svg.append('g')
  .attr 'id', 'nodes'


d3.json '/flare.json', (_, root) ->
  nodes = cluster.nodes root
  links = cluster.links nodes


  link = g.selectAll('.link')
    .data(links)
    .enter()
    .append('path')
    .attr('class', 'link')
    .attr('d', diagonal)


  node = g.selectAll('.node')
    .data(nodes)
    .enter()
    .append('g')
    .attr('class', 'node')
    .attr('d', path)
    .attr('transform', (d) -> "translate(#{d.y}, #{d.x})")
    .on('click', click)


  node.append('circle')
    .attr 'r', 10


  node.append('text')
    .attr('dx', (d) -> if d.children? then -8 else 8)
    .attr('dy', 3)
    .style('text-anchor', (d) -> if d.children? then 'end' else 'start')
    .text (d) -> d.name


click = (d) ->
  if d? and d != centered
    centroid = path.centroid(d)
    x = centroid[0]
    y = centroid[1]
    k = 4
    centered = d
  else
    x = width / 2
    y = height / 2
    k = 1
    centered = null

  g.selectAll('.node')
    .classed('active', centered and ((d) -> d is centered))

  g.transition()
    .duration(1000)
    .attr('transform',
      "translate(#{width / 2}, " +
      "#{height / 2})scale(#{k})translate(#{-x}, #{-y}")
    .style('stroke-width', "#{1.5 / k}px")


d3.select(self.frameElement).style 'height', "#{height}px"
