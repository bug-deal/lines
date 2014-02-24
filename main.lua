function lightLineColor()
  return 230, 230, 230
end

function darkLineColor()
  return 20, 20, 20
end

function love.load()
  -- set up all these globals
  canvas_w = 200
  canvas_h = 200

  scale = 4
  window_w = scale * canvas_w
  window_h = scale * canvas_h

  halted = true

  ox, oy = randomCoords() -- origin x and y
  dx, dy = randomMotion() -- origin movement

  -- set up the window and canvas
  love.window.setMode(window_w, window_h, {borderless = true})
  love.graphics.setBackgroundColor(128, 128, 128)

  canvas = love.graphics.newCanvas()
  canvas:setFilter('nearest') -- uses nearest neighbor scaling when we blow it up later
  love.graphics.setLineStyle('rough') -- unantialiased lines
  love.graphics.setLineWidth(1)

  -- draw to the canvas using the starting origin
  drawLines{x = ox, y = oy}
end

function randomCoords()
  -- the X coordinate for the first one of these is always the same thing.
  -- guess I need to manually seed it with something
  return love.math.random(0, canvas_w), love.math.random(0, canvas_h)
end

function copyPoint(p)
  return {x = p.x, y = p.y}
end

function randomMotion()
  local maxSpeed = 8

  return love.math.random(-maxSpeed, maxSpeed), love.math.random(-maxSpeed, maxSpeed)
end

function drawLines(newOrigin)
  -- tracking all this state in globals right now
  halted = false
  dark = true
  originPoint = copyPoint(newOrigin)
  edgeStart = {x = 0, y = 0}
  edgePoint = copyPoint(edgeStart)
  
  while not halted do
    drawNextLine()
  end
end

function nextEdgePoint(p)
  local ex, ey = p.x, p.y

  if ex <= 0 and ey > 0 then
    -- left edge, moving up
    ex = 0
    ey = ey - 1
  elseif ey <= 0 and ex < canvas_w then
    -- top edge, moving right
    ex = ex + 1
    ey = 0
  elseif ex >= canvas_w and ey < canvas_h then
    -- right edge, moving down
    ex = canvas_w
    ey = ey + 1
  else
    -- bottom edge, moving left
    ex = ex - 1
    ey = canvas_h
  end

  return {x = ex, y = ey}
end

function pointEquals(p1, p2)
  return p1.x == p2.x and p1.y == p2.y
end

function switchColor()
  dark = not dark

  if dark then
    love.graphics.setColor(darkLineColor())
  else
    love.graphics.setColor(lightLineColor())
  end
end

function drawNextLine()
  if halted then return end

  edgePoint = nextEdgePoint(edgePoint)
  switchColor()
  canvas:renderTo(function ()
    love.graphics.line(
      originPoint.x, originPoint.y,
      edgePoint.x, edgePoint.y)
  end)

  if pointEquals(edgePoint, edgeStart) then
    halted = true
  end
end

function love.update(dt)
  ox = ox + dx * dt
  oy = oy + dy * dt

  if ox < 0 then
    ox = -ox
    dx = math.abs(dx)
  elseif ox >= canvas_w then
    ox = 2 * canvas_w - ox
    dx = -math.abs(dx)
  end

  if oy < 0 then
    oy = -oy
    dy = math.abs(dy)
  elseif oy >= canvas_h then
    oy = 2 * canvas_h - oy
    dy = -math.abs(dy)
  end

  drawLines{x = ox, y = oy}
end

function love.draw()
  -- the documentation doesn't explicitly mention this:
  -- by default, current color multiplies the canvas when drawn
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(canvas, 0, 0, 0, scale, scale)
end

function love.mousepressed(mouseX, mouseY, button)
  if button == 'l' then
    ox, oy = mouseX / scale, mouseY / scale
    dx, dy = randomMotion()
  end
end

function love.keypressed(key, isrepeat)
  if key == ' ' then
    dx, dy = randomMotion()
  end

  if key == 'escape' then
    love.event.quit()
  end
end
