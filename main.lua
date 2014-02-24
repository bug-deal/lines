function love.load()
  canvas_w = 200
  canvas_h = 200

  scale = 4
  delay = 4 / 1000 --ms between individual lines

  window_w = scale * canvas_w
  window_h = scale * canvas_h

  halted = false

  love.window.setMode(window_w, window_h)
  love.graphics.setBackgroundColor(128, 128, 128)

  canvas = love.graphics.newCanvas()
  canvas:setFilter('nearest') -- uses nearest neighbor scaling when we blow it up later
  love.graphics.setLineStyle('rough') -- unantialiased lines
  love.graphics.setLineWidth(1)

  startLines()
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

function startLines(new_origin)
  halted = false
  origin = new_origin or randomPoint()
  edge_start = randomEdgePoint()
  edge_current = {x = edge_start.x, y = edge_start.y}
  last_draw_time = love.timer.getTime()
  
  canvas:clear(128, 128, 128)
end

function incrementEdge(p)
  if p.x <= 0 and p.y > 0 then
    -- left edge, moving up
    p.x, p.y = 0, p.y - 1
  elseif p.y <= 0 and p.x < canvas_w then
    -- top edge, moving right
    p.x, p.y = p.x + 1, 0
  elseif p.x >= canvas_w and p.y < canvas_h then
    -- right edge, moving down
    p.x, p.y = canvas_w, p.y + 1
  else
    -- bottom edge, moving left
    p.x, p.y = p.x - 1, canvas_h
  end
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

  incrementEdge(edge_current)
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
  local since_update = love.timer.getTime() - last_draw_time
  local lines_to_draw = math.floor(since_update / delay)
  local spillover = since_update - (lines_to_draw * delay)

  last_draw_time = love.timer.getTime() - spillover

  for i = 1, lines_to_draw do
    drawNextLine()
  end
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

function love.mousepressed(x, y, button)
  if button == 'l' then
    startLines{x = math.floor(x / scale), y = math.floor(y / scale)}
  end
end

function love.keypressed(key, isrepeat)
  if key == ' ' then
    startLines()
  end
end
