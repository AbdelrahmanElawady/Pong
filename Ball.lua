Ball = class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dx = math.random(2) == 1 and 200 or -200
    self.dy = math.random(-50 ,50)
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:collide(paddle)
    if self.x > paddle.x + paddle.width or self.x + self.width < paddle.x then
        return false
    end

    if self.y + self.height < paddle.y or self.y > paddle.y + paddle.height then
        return false
    end

    return true
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    
    self.dx = math.random(2) == 1 and 300 or -300
    self.dy = math.random(-50 ,50)
end