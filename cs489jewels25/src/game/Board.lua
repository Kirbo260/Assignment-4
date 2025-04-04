local Class = require "libs.hump.class"
local Matrix = require "libs.matrix"
local Tween = require "libs.tween"

local Gem = require "src.game.Gem"
local Cursor = require "src.game.Cursor"
local Explosion = require "src.game.Explosion"
local ChainText = require("src.game.ChainText")
local Sounds = require "src.game.SoundEffects"

local Board = Class{}

Board.MAXROWS = 8
Board.MAXCOLS = 8
Board.TILESIZE = Gem.SIZE*Gem.SCALE 

function Board:init(x,y, stats)
    self.x = x
    self.y = y
    self.stats = stats
    self.cursor = Cursor(self.x,self.y,Board.TILESIZE+1)
    self.chainLevel = 0
    
    self.coinRow = math.random(1, Board.MAXROWS)
    self.coinCol = math.random(1, Board.MAXCOLS)

    self.tiles = Matrix:new(Board.MAXROWS,Board.MAXCOLS)
    for i=1, Board.MAXROWS do
        for j=1, Board.MAXCOLS do
            self.tiles[i][j] = self:createGem(i,j)
        end
    end
    self:fixInitialMatrix()

    self.tweenGem1 = nil
    self.tweenGem2 = nil
    self.explosions = {}
    self.arrayFallTweens = {}
    self.chainTexts = {}
end

function Board:createGem(row,col)
    if row == self.coinRow and col == self.coinCol then
        return Gem(self.x+(col-1)*Board.TILESIZE,
                  self.y+(row-1)*Board.TILESIZE,
                  9)
    end
    
    return Gem(self.x+(col-1)*Board.TILESIZE,
               self.y+(row-1)*Board.TILESIZE,
               math.random(4,8))
end

function Board:fixInitialMatrix()
    for i = 1, Board.MAXROWS do
        local same = 1 
        for j = 2, Board.MAXCOLS do
            if self.tiles[i][j].type == 9 or self.tiles[i][j-1].type == 9 then
                same = 1
            elseif self.tiles[i][j].type == self.tiles[i][j-1].type then
                same = same+1
                if same == 3 then
                    self.tiles[i][j]:nextType()
                    same = 1
                end
            else
                same = 1
            end
        end
    end

    for j = 1, Board.MAXCOLS do
        local same = 1 
        for i = 2, Board.MAXROWS do
            if self.tiles[i][j].type == 9 or self.tiles[i-1][j].type == 9 then
                same = 1
            elseif self.tiles[i][j].type == self.tiles[i-1][j].type then
                same = same+1
                if same == 3 then
                    self.tiles[i][j]:nextType()
                    same = 1
                end
            else
                same = 1
            end
        end
    end    
end

function Board:update(dt)
    for i=1, Board.MAXROWS do
        for j=1, Board.MAXCOLS do
            if self.tiles[i][j] then
                self.tiles[i][j]:update(dt)
            end
        end
    end

    for k=#self.explosions, 1, -1 do
        if self.explosions[k]:isActive() then
            self.explosions[k]:update(dt)
        else
            table.remove(self.explosions, k)
        end
    end

    for k=#self.arrayFallTweens, 1, -1 do
        if self.arrayFallTweens[k]:update(dt) then
            table.remove(self.arrayFallTweens, k)
        end
    end

    for k=#self.chainTexts, 1, -1 do
        if self.chainTexts[k]:isActive() then
            self.chainTexts[k]:update(dt)
        else
            table.remove(self.chainTexts, k)
        end
    end

    if #self.arrayFallTweens == 0 then
        self:matches()
    end

    if self.tweenGem1 ~= nil and self.tweenGem2~=nil then
        local completed1 = self.tweenGem1:update(dt)
        local completed2 = self.tweenGem2:update(dt)
        if completed1 and completed2 then
            self.tweenGem1 = nil
            self.tweenGem2 = nil
            local temp = self.tiles[mouseRow][mouseCol]
            self.tiles[mouseRow][mouseCol] = self.tiles[self.cursor.row][self.cursor.col]
            self.tiles[self.cursor.row][self.cursor.col] = temp
            self.cursor:clear()
            self:matches()
        end
    end
end

function Board:draw()
    for i=1, Board.MAXROWS do
        for j=1, Board.MAXCOLS do
            if self.tiles[i][j] then
                self.tiles[i][j]:draw()
            end
        end
    end

    self.cursor:draw()

    for k=1, #self.explosions do
        self.explosions[k]:draw()
    end

    for k=1, #self.chainTexts do
        self.chainTexts[k]:draw()
    end
end

function Board:cheatGem(x,y)
    if x > self.x and y > self.y 
       and x < self.x+Board.MAXCOLS*Board.TILESIZE
       and y < self.y+Board.MAXROWS*Board.TILESIZE then
        local cheatRow,cheatCol = self:convertPixelToMatrix(x,y)
        self.tiles[cheatRow][cheatCol]:nextType()
    end
end

function Board:mousepressed(x,y)
    if x > self.x and y > self.y 
       and x < self.x+Board.MAXCOLS*Board.TILESIZE
       and y < self.y+Board.MAXROWS*Board.TILESIZE then
        mouseRow, mouseCol = self:convertPixelToMatrix(x,y)

        if self.cursor.row == mouseRow and self.cursor.col == mouseCol then
            self.cursor:clear()
        elseif self:isAdjacentToCursor(mouseRow,mouseCol) then
            self:tweenStartSwap(mouseRow,mouseCol,self.cursor.row,self.cursor.col)
        else
            self.chainLevel = 0
            self.cursor:setCoords(self.x+(mouseCol-1)*Board.TILESIZE,
                    self.y+(mouseRow-1)*Board.TILESIZE)
            self.cursor:setMatrixCoords(mouseRow,mouseCol)
        end
    end
end

function Board:isAdjacentToCursor(row,col)
    local adjCol = self.cursor.row == row 
       and (self.cursor.col == col+1 or self.cursor.col == col-1)
    local adjRow = self.cursor.col == col 
       and (self.cursor.row == row+1 or self.cursor.row == row-1)
    return adjCol or adjRow
end

function Board:convertPixelToMatrix(x,y)
    local col = 1+math.floor((x-self.x)/Board.TILESIZE)
    local row = 1+math.floor((y-self.y)/Board.TILESIZE)
    return row,col 
end

function Board:tweenStartSwap(row1,col1,row2,col2)
    self.chainLevel = 0
    local x1 = self.tiles[row1][col1].x
    local y1 = self.tiles[row1][col1].y
    local x2 = self.tiles[row2][col2].x
    local y2 = self.tiles[row2][col2].y
    self.tweenGem1 = Tween.new(0.3,self.tiles[row1][col1],{x=x2,y=y2})
    self.tweenGem2 = Tween.new(0.3,self.tiles[row2][col2],{x=x1,y=y1})
end

function Board:findHorizontalMatches()
    local matches = {}
    for i = 1, Board.MAXROWS do 
        local same = 1
        for j = 2, Board.MAXCOLS do
            if self.tiles[i][j] and self.tiles[i][j-1] and 
               self.tiles[i][j].type == self.tiles[i][j-1].type then
                same = same +1
            elseif same > 2 then
                table.insert(matches,{row=i, col=(j-same), size=same})
                same = 1
            else
                same = 1
            end
        end

        if same > 2 then
            table.insert(matches,{row=i, col=(Board.MAXCOLS-same+1), size=same})
            same = 1
        end
    end

    return matches
end

function Board:findVerticalMatches()
    local matches = {}
    for j = 1, Board.MAXCOLS do 
        local same = 1
        for i = 2, Board.MAXROWS do
            if self.tiles[i][j] and self.tiles[i-1][j] and 
               self.tiles[i][j].type == self.tiles[i-1][j].type then
                same = same +1
            elseif same > 2 then
                table.insert(matches,{row=(i-same), col=j, size=same})
                same = 1
            else
                same = 1
            end
        end

        if same > 2 then
            table.insert(matches,{row=(Board.MAXROWS+1-same), col=j, size=same})
            same = 1
        end
    end

    return matches
end

function Board:isAdjacentToCoin(row, col)
    if row == self.coinRow and col == self.coinCol then
        return false
    end

    local rowDiff = math.abs(row - self.coinRow)
    local colDiff = math.abs(col - self.coinCol)
    return rowDiff <= 1 and colDiff <= 1
end

function Board:matches()
    local matchFound = false
    local matchedGems = {}
    local adjacentToCoinCount = 0

    for i = 1, Board.MAXROWS do
        local same = 1
        local gemType = self.tiles[i][1] and self.tiles[i][1].type
        for j = 2, Board.MAXCOLS do
            if self.tiles[i][j] and self.tiles[i][j-1] and 
               self.tiles[i][j].type == self.tiles[i][j-1].type then
                same = same + 1
                if same >= 3 then
                    matchFound = true
                    for k = 0, same-1 do
                        matchedGems[#matchedGems + 1] = {row = i, col = j-k}
                    end
                end
            else
                same = 1
                gemType = self.tiles[i][j] and self.tiles[i][j].type
            end
        end
    end

    for j = 1, Board.MAXCOLS do
        local same = 1
        local gemType = self.tiles[1][j] and self.tiles[1][j].type
        for i = 2, Board.MAXROWS do
            if self.tiles[i][j] and self.tiles[i-1][j] and 
               self.tiles[i][j].type == self.tiles[i-1][j].type then
                same = same + 1
                if same >= 3 then
                    matchFound = true
                    for k = 0, same-1 do
                        matchedGems[#matchedGems + 1] = {row = i-k, col = j}
                    end
                end
            else
                same = 1
                gemType = self.tiles[i][j] and self.tiles[i][j].type
            end
        end
    end

    if matchFound then
        local coinMatched = false
        for _, gem in ipairs(matchedGems) do
            if gem.row == self.coinRow and gem.col == self.coinCol then
                coinMatched = true
            elseif self:isAdjacentToCoin(gem.row, gem.col) then
                adjacentToCoinCount = adjacentToCoinCount + 1
                print("Found match adjacent to coin at row:", gem.row, "col:", gem.col)
                if not coinMatched then
                    matchedGems[#matchedGems + 1] = {row = self.coinRow, col = self.coinCol}
                    coinMatched = true
                end
            end
        end

        for _, gem in ipairs(matchedGems) do
            if self.tiles[gem.row] and self.tiles[gem.row][gem.col] then
                local gemType = self.tiles[gem.row][gem.col].type
                local r,g,b = self.tiles[gem.row][gem.col]:getColor()
                
                local exp = Explosion()
                exp:setColor(r,g,b)
                
                if self:isAdjacentToCoin(gem.row, gem.col) then
                    exp:setScale(1.5)
                end
                    
                exp:trigger(self.x+(gem.col-1)*Board.TILESIZE+Board.TILESIZE/2,
                           self.y+(gem.row-1)*Board.TILESIZE+Board.TILESIZE/2)
                table.insert(self.explosions, exp)
                
                self.tiles[gem.row][gem.col] = nil
            end
        end

        if coinMatched then
            self:moveCoinToRandomPosition()
        end

        self.chainLevel = self.chainLevel + 1

        local baseScore = math.min(#matchedGems * 80 / 3, 1000)
        local chainMultiplier = math.min(1 + (self.chainLevel - 1) * 0.5, 3.0)
        local coinBonus = math.min(1 + (adjacentToCoinCount * 0.5), 2.0)
        local finalScore = math.floor(baseScore * chainMultiplier * coinBonus)
        
        self.stats:addScore(finalScore)

        local textX = self.x + (Board.MAXCOLS * Board.TILESIZE) + 100
        local textY = self.y + (Board.MAXROWS * Board.TILESIZE) / 2
        local chainText
        if adjacentToCoinCount > 0 then
            chainText = ChainText(textX, textY, 
                string.format("Chain %d! (+%d%%)", 
                    self.chainLevel, 
                    math.floor((coinBonus - 1) * 100)))
        else
            chainText = ChainText(textX, textY, "Chain " .. self.chainLevel .. "!")
        end
        table.insert(self.chainTexts, chainText)

        self:generateNewGems()
        return true
    end

    self.chainLevel = 0
    return false
end

function Board:createExplosion(row,col,r,g,b)
    local exp = Explosion()
    if r and g and b then
        exp:setColor(r,g,b)
    end
    exp:trigger(self.x+(col-1)*Board.TILESIZE+Board.TILESIZE/2,
               self.y+(row-1)*Board.TILESIZE+Board.TILESIZE/2)  
    table.insert(self.explosions, exp)
end

function Board:shiftGems()
    for j = 1, Board.MAXCOLS do
        local coinInColumn = false
        for i = Board.MAXROWS, 1, -1 do
            if self.tiles[i][j] and self.tiles[i][j].type == 9 then
                self.coinRow = i
                self.coinCol = j
                coinInColumn = true
                break
            end
        end
    end

    for j = 1, Board.MAXCOLS do
        local spaces = 0
        for i = Board.MAXROWS, 1, -1 do
            if self.tiles[i][j] == nil then
                spaces = spaces + 1
            elseif spaces > 0 then
                local gem = self.tiles[i][j]
                self.tiles[i][j] = nil
                self.tiles[i+spaces][j] = gem
                
                if gem.type == 9 then
                    self.coinRow = i + spaces
                    self.coinCol = j
                end
                
                local tween = Tween.new(0.2, gem, 
                    {y = self.y+(i+spaces-1)*Board.TILESIZE},
                    'outBounce')
                table.insert(self.arrayFallTweens, tween)
            end
        end
    end
end

function Board:generateNewGems()
    self:shiftGems()
    
    for j = 1, Board.MAXCOLS do
        local spaces = 0
        for i = 1, Board.MAXROWS do
            if self.tiles[i][j] == nil then
                spaces = spaces + 1
                local newGem = Gem(
                    self.x+(j-1)*Board.TILESIZE,
                    self.y-(spaces)*Board.TILESIZE,
                    math.random(4,8)
                )
                self.tiles[i][j] = newGem
                
                local tween = Tween.new(0.2, newGem,
                    {y = self.y+(i-1)*Board.TILESIZE},
                    'outBounce')
                table.insert(self.arrayFallTweens, tween)
            end
        end
    end
end

function Board:moveCoinToRandomPosition()
    local oldRow, oldCol = self.coinRow, self.coinCol
    
    repeat
        self.coinRow = math.random(1, Board.MAXROWS)
        self.coinCol = math.random(1, Board.MAXCOLS)
    until (self.coinRow ~= oldRow or self.coinCol ~= oldCol) and
          not self:wouldCreateMatch(self.coinRow, self.coinCol, 9)
    
    if self.tiles[self.coinRow][self.coinCol] then
        self.tiles[self.coinRow][self.coinCol] = Gem(
            self.x+(self.coinCol-1)*Board.TILESIZE,
            self.y+(self.coinRow-1)*Board.TILESIZE,
            9
        )
    end
end

function Board:wouldCreateMatch(row, col, gemType)
    local originalGem = self.tiles[row][col]
    
    self.tiles[row][col] = Gem(
        self.x+(col-1)*Board.TILESIZE,
        self.y+(row-1)*Board.TILESIZE,
        gemType
    )
    
    local horizontalMatch = false
    if col > 2 then
        horizontalMatch = horizontalMatch or 
            (self.tiles[row][col-2] and self.tiles[row][col-1] and
             self.tiles[row][col-2].type == gemType and
             self.tiles[row][col-1].type == gemType)
    end
    if col < Board.MAXCOLS-1 and col > 1 then
        horizontalMatch = horizontalMatch or
            (self.tiles[row][col-1] and self.tiles[row][col+1] and
             self.tiles[row][col-1].type == gemType and
             self.tiles[row][col+1].type == gemType)
    end
    if col < Board.MAXCOLS-2 then
        horizontalMatch = horizontalMatch or
            (self.tiles[row][col+1] and self.tiles[row][col+2] and
             self.tiles[row][col+1].type == gemType and
             self.tiles[row][col+2].type == gemType)
    end
    
    local verticalMatch = false
    if row > 2 then
        verticalMatch = verticalMatch or
            (self.tiles[row-2][col] and self.tiles[row-1][col] and
             self.tiles[row-2][col].type == gemType and
             self.tiles[row-1][col].type == gemType)
    end
    if row < Board.MAXROWS-1 and row > 1 then
        verticalMatch = verticalMatch or
            (self.tiles[row-1][col] and self.tiles[row+1][col] and
             self.tiles[row-1][col].type == gemType and
             self.tiles[row+1][col].type == gemType)
    end
    if row < Board.MAXROWS-2 then
        verticalMatch = verticalMatch or
            (self.tiles[row+1][col] and self.tiles[row+2][col] and
             self.tiles[row+1][col].type == gemType and
             self.tiles[row+2][col].type == gemType)
    end
    
    self.tiles[row][col] = originalGem
    
    return horizontalMatch or verticalMatch
end

return Board