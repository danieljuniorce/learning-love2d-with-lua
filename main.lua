_G.love = require('love')

local anim8, player, sti, camera, windfield, world, gameMap, cam, walls

function love.load()
  camera = require('libraries/camera')
  anim8 = require('libraries/anim8')
  windfield = require('libraries/windfield')

  world = windfield.newWorld(0, 0)

  love.graphics.setDefaultFilter('nearest', 'nearest')

  sti = require('libraries/sti')
  gameMap = sti('maps/maps.lua')
  cam = camera()

  player = {}
  player.collider = world:newBSGRectangleCollider(400, 250, 50, 80, 10)
  player.collider:setFixedRotation(true)
  player.posX = 0
  player.posY = 0
  player.speed = 300
  player.spritesheet = love.graphics.newImage('assets/player-sheet.png')
  player.grid = anim8.newGrid(12, 18, player.spritesheet:getWidth(), player.spritesheet:getHeight())

  player.animations = {}
  player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
  player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
  player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
  player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

  player.anim = player.animations.left

  walls = {}

  if gameMap.layers["Colision"] then
    for i, obj in pairs(gameMap.layers["Colision"].objects) do
      local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
      wall:setType("static")

      table.insert(walls, wall)
    end
  end
end

function love.update(dt)
  local isMoving = false
  local vx = 0
  local vy = 0

  if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
    vx = player.speed
    player.anim = player.animations.right
    isMoving = true
  end

  if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
    vx = player.speed * -1
    player.anim = player.animations.left
    isMoving = true
  end

  if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
    vy = player.speed * -1
    player.anim = player.animations.up
    isMoving = true
  end

  if love.keyboard.isDown('s') or love.keyboard.isDown('down') then
    vy = player.speed
    player.anim = player.animations.down
    isMoving = true
  end

  player.collider:setLinearVelocity(vx, vy)

  if isMoving == false then
    player.anim:gotoFrame(2)
  end

  world:update(dt)
  player.posX = player.collider:getX()
  player.posY = player.collider:getY()

  player.anim:update(dt)
  cam:lookAt(player.posX, player.posY)


  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  if cam.x < width / 2 then
    cam.x = width / 2
  end

  if cam.y < height / 2 then
    cam.y = height / 2
  end

  local mapWidth = gameMap.width * gameMap.tilewidth
  local mapHeight = gameMap.height * gameMap.tileheight

  if cam.x > (mapWidth - width / 2) then
    cam.x = (mapWidth - width / 2)
  end

  if cam.y > (mapHeight - height / 2) then
    cam.y = (mapHeight - height / 2)
  end
end

function love.draw()
  cam:attach()
  gameMap:drawLayer(gameMap.layers['chao'])
  gameMap:drawLayer(gameMap.layers['seed'])
  gameMap:drawLayer(gameMap.layers['colisions'])
  player.anim:draw(player.spritesheet, player.posX, player.posY, nil, 5, nil, 6, 9)
  cam:detach()
end
