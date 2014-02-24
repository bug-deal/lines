function love.load()
  canvas_w = 200
  canvas_h = 200

  scale = 4
  delay = 4 / 1000 --ms between individual lines

  window_w = scale * canvas_w
  window_h = scale * canvas_h

  halted = true

  love.window.setMode(window_w, window_h)
  love.graphics.setBackgroundColor(128, 128, 128)

  canvas = love.graphics.newCanvas()
  canvas:setFilter('nearest') -- uses nearest neighbor scaling when we blow it up later
  love.graphics.setLineStyle('rough') -- unantialiased lines
  love.graphics.setLineWidth(1)

  local randPoint = randomPoint()
  x = randPoint.x
  y = randPoint.y
  randomizeMotion()

  drawLines{x = x, y = y}
end

function randomPoint()
  return {
    x = love.math.random(canvas_w),
    y = love.math.random(canvas_h)
  }
end

function copyPoint(p)
  return {x = p.x, y = p.y}
end

function randomEdgePoint()
  local randPoint = randomPoint()

  return randomFrom(
    -- top edge
    { x = randPoint.x, y = 0 },
    -- right edge
    { x = canvas_w, y = randPoint.y },
    -- bottom edge
    { x = randPoint.x, y = canvas_h },
    -- left edge
    { x = 0, y = randPoint.y }
  )
end

function randomFrom(...)
  local numArgs = select('#', ...)
  local index = love.math.random(1, numArgs)
  return ({...})[index]
end

function randomizeMotion()
  local maxSpeed = 12

  dx = love.math.random(-maxSpeed, maxSpeed)
  dy = love.math.random(-maxSpeed, maxSpeed)
end

function drawLines(new_origin)
  halted = false
  black = true
  origin = new_origin or randomPoint()
  edge_start = {x = 0, y = 0}
  edge_current = {x = edge_start.x, y = edge_start.y}
  
  while not halted do
    drawNextLine()
  end
end

function incrementEdge()
  -- there's probably a way better way to write this
  local on_edge = nil
  local curr_x = edge_current.x
  local curr_y = edge_current.y

  if curr_x <= 0 then
    if curr_y <= 0 then
      on_edge = 'top'
    else
      on_edge = 'left'
    end
  elseif curr_y <= 0 then
    if curr_x >= canvas_w then
      on_edge = 'right'
    else
      on_edge = 'top'
    end
  elseif curr_x >= canvas_w then
    if curr_y >= canvas_h then
      on_edge = 'bottom'
    else
      on_edge = 'right'
    end
  elseif curr_y >= canvas_h then
    on_edge = 'bottom'
  end

  if on_edge == 'top' then
    edge_current.x = curr_x + 1
    edge_current.y = 0
  elseif on_edge == 'right' then
    edge_current.x = canvas_w
    edge_current.y = curr_y + 1
  elseif on_edge == 'bottom' then
    edge_current.x = curr_x - 1
    edge_current.y = canvas_h
  else -- left
    edge_current.x = 0
    edge_current.y = curr_y - 1
  end

  info = 'edge: '..on_edge..
    '\nfrom: '..curr_x..', '..curr_y..
    '\nto:'..(edge_current.x)..', '..(edge_current.y)
end

function pointEquals(p1, p2)
  return p1.x == p2.x and p1.y == p2.y
end

function switchColor()
  if black then
    love.graphics.setColor(255, 255, 255)
    black = false
  else
    love.graphics.setColor(0, 0, 0)
    black = true
  end
end

function drawNextLine()
  if halted then return end

  incrementEdge()
  switchColor()
  canvas:renderTo(function ()
    love.graphics.line(
      origin.x, origin.y,
      edge_current.x, edge_current.y)
  end)

  if pointEquals(edge_current, edge_start) then
    halted = true
  end
end

function love.update(dt)
  x = x + dx * dt
  y = y + dy * dt

  if x < 0 then
    x = -x
    dx = math.abs(dx)
  elseif x >= canvas_w then
    x = 2 * canvas_w - x
    dx = -math.abs(dx)
  end

  if y < 0 then
    y = -y
    dy = math.abs(dy)
  elseif y >= canvas_h then
    y = 2 * canvas_h - y
    dy = -math.abs(dy)
  end

  drawLines{x = x, y = y}
end

function outputDebugInfo()
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('fill', 10, 10, 300, 100)

  love.graphics.setColor(0, 0, 0)
  love.graphics.print(
    'Origin: '..(origin.x)..', '..(origin.y)..
    '\nEdge: '..(edge_current.x)..', '..(edge_current.y)..
    '\nInfo: '..(info or '')
  , 20, 20)
end

function love.draw()
  -- the documentation doesn't explicitly mention this:
  -- by default, current color multiplies the canvas when drawn
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(canvas, 0, 0, 0, scale, scale)
  --outputDebugInfo()
end

function love.mousepressed(mouseX, mouseY, button)
  if button == 'l' then
    x, y = mouseX / scale, mouseY / scale
    randomizeMotion()
  end
end

function love.keypressed(key, isrepeat)
  if key == ' ' then
    randomizeMotion()
  end
end
