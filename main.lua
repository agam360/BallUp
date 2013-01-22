-- Created by Agam More

local sw = 800 -- Screen width
local sh = 600 -- Screen height
local mStartX = 0 -- Mouse start X position
local mStartY = 0 -- Mouse start Y position
local mEndX = 0 -- Mouse end X position
local mEndY = 0 -- Mouse end Y position
local gameWon = false -- End game loop
local hScore = 0 -- Height score

function love.load()

	-- Create a new world with a 150 force scale downwards
	world = love.physics.newWorld( 0, 150, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	walls = {}
	walls.count = 0

	wHelper = {}
	wHelper.b = love.physics.newBody(world, 0, 0, "static")
	wHelper.s = love.physics.newEdgeShape(0,0,0,0)
	wHelper.f = love.physics.newFixture(wHelper.b, wHelper.s, 1)
	wHelper.xStart = 0
	wHelper.yStart = 0

	ball = {}
	ball.b = love.physics.newBody(world, 0,0, "dynamic")
	ball.s = love.physics.newCircleShape(8)
	ball.f = love.physics.newFixture(ball.b, ball.s, 1)
  	ball.b:setMass(0.8)
    ball.f:setRestitution(0.3)
    ball.f:setFriction(0)
    ball.b:setX(75)
    ball.b:setY(75)
    ball.f:setUserData("col")

    objective = {}
    objective.b = love.physics.newBody(world, 0,0, "static")
    objective.s = love.physics.newRectangleShape( 50, 50 )
    objective.f = love.physics.newFixture(objective.b,  objective.s, 1)
    objective.f:setUserData("col") -- checks for collisions
    objective.b:setX(math.random()*(sw-50)+50)
    objective.b:setY(math.random()*(sh-90)+90)

end

function love.update(dt)

	world:update(dt)

	-- Create a wall helper (grey wall)
	if love.mouse.isDown("l") then
		local x, y = love.mouse.getPosition()
		wHelper.s = love.physics.newEdgeShape( wHelper.xStart, wHelper.yStart, x, y )
	end

	bx = ball.b:getX()
	by = ball.b:getY()
	xV, yV = ball.b:getLinearVelocity()

	-- Check if the ball is out of bounds or not moving
	if bx > sw or bx < 0 or by > sh or by < 0 or (xV == 0 and yV == 0) then
		ball.b:setLinearVelocity(0, 0)
		ball.b:setX(75)
    	ball.b:setY(75)
    	hScore = 0
	end
	
	-- Check for upwards velocity
	if yV < 0 and not gameWon then
		hScore = hScore + 1
	end

end

function love.draw()

	if not gameWon then
		-- Draw circle starting point:
		love.graphics.setColor(20, 20, 220, 105)
		love.graphics.rectangle("fill", 50, 50, 50, 50 )

		-- Wall helper
		love.graphics.setColor(120, 120, 120, 255)
		love.graphics.line(wHelper.b:getWorldPoints(wHelper.s:getPoints()))

		-- Ball
		love.graphics.setColor(180, 14, 14, 255)
		love.graphics.circle("fill", ball.b:getX(), ball.b:getY(), ball.s:getRadius() )

		love.graphics.setColor(0, 255, 0, 255)
		for i,b in ipairs(walls) do
	        love.graphics.line(walls[i].b:getWorldPoints(walls[i].s:getPoints()))
	    end
	    love.graphics.setColor(0, 100, 200, 255)
	    love.graphics.print("Height Score: "..hScore, sw/3, 30)
	    --Draw objective
	    love.graphics.setColor(245, 20, 20, 125)
	    love.graphics.polygon( "fill", objective.b:getWorldPoints(objective.s:getPoints()))
	else 
		love.graphics.setColor(0, 255, 0, 255)
    	love.graphics.print("You won!\nScore: "..hScore.."\nPress r to play agian.", sw/3, sh/3)
	end

end

--Restart game
function love.keyreleased(key)
   if key == "r" then
      gameWon = false
      hScore = 0
	  love.load() -- restart whole game
   end
end

-- Record mouse interactions for the Wall Helper
function love.mousepressed(x, y, button)
	if button == "l" then
		mStartX = x
		mStartY = y
		wHelper.xStart = x
		wHelper.yStart = y
	end
end

--Insert new "wall"
function love.mousereleased(x, y, button)
	if button == "l" then
		walls.count = walls.count + 1
		i = walls.count
		walls[i] = {}
		walls[i].b = love.physics.newBody(world, 0, 0, "static")
	  	walls[i].s = love.physics.newEdgeShape(mStartX, mStartY, x, y)
	  	walls[i].f = love.physics.newFixture(walls[i].b, walls[i].s, 1 )
	  	walls[i].f:setFriction(0.1)
	end
end

-- Collisions:
function beginContact(a, b, coll)
	-- Check if fixtures are the ball and objective
    if a:getUserData() == "col" and b:getUserData() == "col" then
    	gameWon = true
    end
end

function endContact(a, b, coll)
end
function preSolve(a, b, coll)
end
function postSolve(a, b, coll)
end