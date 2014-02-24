function lineColor1()
  return 230, 230, 230
end

function lineColor2()
  return 20, 20, 20
end

function love.load()
  canvas_w = 200
  canvas_h = 200

  scale = 4

  window_w = scale * canvas_w
  window_h = scale * canvas_h

  halted = true

  love.window.setMode(window_w, window_h, {borderless = true})
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
    x = love.math.random(canvas_w - 1),
    y = love.math.random(canvas_h - 1)
  }
end

function copyPoint(p)
  return {x = p.x, y = p.y}
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
    love.graphics.setColor(lineColor1())
    black = false
  else
    love.graphics.setColor(lineColor2())
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

function love.draw()
  -- the documentation doesn't explicitly mention this:
  -- by default, current color multiplies the canvas when drawn
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(canvas, 0, 0, 0, scale, scale)
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

  if key == 'escape' then
    love.event.quit()
  end
end
