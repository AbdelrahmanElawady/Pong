WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

class = require 'class'
push = require 'push'

require 'Paddle'
require 'Ball'

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_lost'] = love.audio.newSource('point_lost.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')
    }
    
    player1Score = 0
    player2Score = 0

    winner = 0

    paddle1 = Paddle(5, 20, 5, 30)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 40, 5, 30)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

    servingPlayer = math.random(2) == 1 and 1 or 2

    if servingPlayer == 1 then
        ball.dx = 300
    else
        ball.dx = -300
    end

    gameState = 'Start'

end

function love.update(dt)
    if gameState == 'Play' then

        paddle1:update(dt)
        paddle2:update(dt)

        if ball.x <= 0 then
            servingPlayer = 2
            player2Score = player2Score + 1
            ball:reset()
            ball.dx = -300
            sounds['point_lost']:play()
            if player2Score >= 3 then
                gameState = 'Victory'
                winner = 2
            else
                gameState = 'Serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - ball.width then
            servingPlayer = 1
            player1Score = player1Score + 1
            ball:reset()
            ball.dx = 300
            sounds['point_lost']:play()
            if player1Score >= 3 then
                gameState = 'Victory'
                winner = 1
            else
                gameState = 'Serve'
            end
        end

        if ball:collide(paddle1) then
            ball.dx = 300
            sounds['paddle_hit']:play()
            ball.dy = math.random(-50,50)
        end
        if ball:collide(paddle2) then
            ball.dx = -300
            sounds['paddle_hit']:play()
            ball.dy = math.random(-50,50)
        end

        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 5 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 5
            sounds['wall_hit']:play()
        end

        if love.keyboard.isDown('w') then
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0 
        end

        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddle2.dy = PADDLE_SPEED
        else
            paddle2.dy = 0
        end
        
            ball:update(dt)
    end
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'Start' then 
            gameState = 'Play'
        elseif gameState == 'Serve' then
            gameState = 'Play'
        elseif gameState == 'Victory' then
            player2Score = 0
            player1Score = 0
            gameState = 'Start'
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    ball:render()
    
    paddle1:render()
    paddle2:render()

    love.graphics.setFont(smallFont)

    if gameState == 'Start' then
        love.graphics.printf('Welcome to Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter to start', 0, 32, VIRTUAL_WIDTH, 'center') 
    elseif gameState == 'Serve' then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter to start', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'Victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf('Player ' .. tostring(winner) .. ' is the winner!', 0, 10, VIRTUAL_WIDTH ,'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press enter to start', 0, 42, VIRTUAL_WIDTH ,'center')
    end


    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end