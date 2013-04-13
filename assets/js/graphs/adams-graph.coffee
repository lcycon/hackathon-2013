margin = [20, 120, 20, 120]
pageW = 960
pageH = window.outerHeight
width = pageW - margin[1] - margin[3]
height = pageH - margin[0] - margin[2]
SMALL_CIRCLE_RADIUS = 0
BIG_CIRCLE_RADIUS = 10
MAX_EXPAND = 4
index = 0
root = undefined
API_URL = '/api/user'
activeD = null


tree = d3.layout.tree()
  .size [height, width]


diagonal = d3.svg.diagonal()
  .projection (d) -> [d.y, d.x]


vis = d3.select('#content').append('svg:svg')
  .attr('width', pageW)
  .attr('height', pageH)
  .append('svg:g')
  .attr('transform', "translate(#{margin[3]}, #{margin[0]})")


d3.json "#{API_URL}/#{window.user}", (json) ->
  window.spinner.stop()
  document.getElementById('spin').style.display = 'none'
  document.getElementById('content').style.display = 'block'
  root = json
  root.x0 = 0
  root.y0 = width / 2
  root.depth = 0

  root.children.forEach (d) -> d.depth = 1

  toggleAll = (d) ->
    if d.children?
      d.children.forEach toggleAll
      toggle d
  update root


hasChildrenColor = (d) ->
  if d._children?
    'lightsteelblue'
  else if d.depth is MAX_EXPAND
    '#ccc'
  else
    '#fff'


hasChildrenText = (d) ->
  if d.children? or d._children?
    -10
  else
    10


hasChildrenAnchor = (d) ->
  if d.children? or d._children?
    'end'
  else
    'start'


click = (d) ->
  if d.children? or d._children? or d.depth >= MAX_EXPAND or activeD is d
    toggle(d)
    update(d)
  else
    activeD = d
    d3.json "#{API_URL}/#{d.name}", (data) ->
      d.depth += 1
      d.children = data.children
      update(d)
      activeD = null


update = (src) ->
  duration = if d3.event? and d3.event.altKey then 5000 else 500

  # Compute the new tree layout
  nodes = tree.nodes(root).reverse()

  # Normalize for fixed-depth
  nodes.forEach (d) -> d.y = d.depth * 180

  # Update the nodes
  node = vis.selectAll('g.node')
    .data(nodes, (d) -> d.id or (d.id = ++index))

  # Enter any new nodes at the parent's previous position
  nodeEnter = node.enter().append('svg:g')
    .attr('class', 'node')
    .attr('transform', (d) -> "translate(#{src.y0}, #{src.x0})")
    .style('cursor', (d) -> if d.depth is MAX_EXPAND then 'default')
    .on('click', click)


  nodeEnter.append('svg:circle')
    .attr('r', SMALL_CIRCLE_RADIUS)
    .style('cursor', (d) -> if d.depth is MAX_EXPAND then 'default')
    .style('fill', hasChildrenColor)

  nodeEnter.append('svg:text')
    .attr('x', hasChildrenText)
    .attr('dy', '.35em')
    .attr('text-anchor', hasChildrenAnchor)
    .attr('color', 'white')
    .text((d) -> d.name)
    .style('fill-opacity', SMALL_CIRCLE_RADIUS)

  # Transition nodes to their new positions
  nodeUpdate = node.transition()
    .duration(duration)
    .attr('transform', (d) -> "translate(#{d.y}, #{d.x})")

  nodeUpdate.select('circle')
    .attr('r', BIG_CIRCLE_RADIUS)
    .style('fill', hasChildrenColor)

  nodeUpdate.select('text')
    .style('fill-opacity', 1)

  # Transition exiting nodes to the parent's new position
  nodeExit = node.exit().transition()
    .duration(duration)
    .attr('transform', (d) -> "translate(#{src.y}, #{src.x})")
    .remove()

  nodeExit.select('circle')
    .attr('r', SMALL_CIRCLE_RADIUS)

  nodeExit.select('text')
    .style('fill-opacity', SMALL_CIRCLE_RADIUS)

  # Update link
  link = vis.selectAll('path.link')
    .data(tree.links(nodes), (d) -> d.target.id)

  link.enter().insert('svg:path', 'g')
    .attr('class', 'link')
    .attr('d', (d) ->
      o = {x: src.x0, y: src.y0}
      diagonal {source: o, target: o}
    )
    .transition()
    .duration(duration)
    .attr('d', diagonal)

  link.transition()
    .duration(duration)
    .attr('d', diagonal)

  # Transition exiting links to the parents new position
  link.exit().transition()
    .duration(duration)
    .attr('d', (d) ->
      o = {x: src.x, y: src.y}
      diagonal {source: o, target: o}
    )
    .remove()

  # Stash the old positions for transition
  nodes.forEach (d) ->
    d.x0 = d.x
    d.y0 = d.y


# Toggle children
toggle = (d) ->
  if d.children?
    d._children = d.children
    d.children = null
  else
    d.children = d._children
    d._children = null

