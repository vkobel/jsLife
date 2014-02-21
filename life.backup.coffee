
class Canvas
  constructor: (name) ->
    @elem   = document.getElementById name
    @ctx    = @elem.getContext "2d"
    @width  = @elem.width
    @height = @elem.height

  draw: (x, y, sizeX, sizeY, color) ->
    @ctx.fillStyle = color
    @ctx.fillRect x, y, sizeX, sizeY

  clear: ->
    @ctx.clearRect 0, 0, @width, @height

class Grid extends Canvas
  constructor: (name, @sizeX, @sizeY) ->
    super name
    @matrix = (new Array(@height / @sizeY) for i in [1..(@width / @sizeX)])
    
  buildPotentialStateChanging: () ->
    @potentialStateChanging = {}
    for _, x in @matrix
      for _, y in @matrix[x]
        @potentialStateChanging[x+','+y] = [x, y] if @matrix[x][y]?

  draw: (x, y, color) ->
    super x * @sizeX, y * @sizeY, @sizeX, @sizeY, color ? "#420606"

  live: (x, y) ->
    @draw x, y, "#FAB23E"
    @matrix[x][y] = true

    #push if not duplicate
    #@potentialStateChanging.push [x, y]

  die: (x, y) ->
    @draw x, y, undefined
    @matrix[x][y] = undefined

  isAlive: (matr, x, y) ->
    matr[x][y]?

  neighboursCount: (matr, x, y) ->
    nb = 0
    nb++ for px in @getAdjacentCoords(x, y) when matr[px[0]][px[1]] is not undefined
    nb

  getAdjacentCoords: (x, y) ->
    [[x-1, y-1], [x, y-1], [x+1, y-1],
     [x-1, y], [x+1, y],
     [x-1, y+1], [x, y+1], [x+1, y+1]]

class GameLoop
  constructor: (fps, @grid) ->
    @dur = 1000 / fps

  compute: =>
    tmp = (itm.slice() for itm in @grid.matrix) # make copy of the array

    for _, x in tmp
      for _, y in tmp[x]

        count = @grid.neighboursCount tmp, x, y

        if @grid.isAlive tmp, x, y
          if count < 2
            @grid.die x, y

          if count == 2 or count == 3
            @grid.live x, y

          if count > 3
            @grid.die x, y

        else
          if count == 3
            @grid.live x, y
  
  start: ->
    window.setInterval(@compute, @dur)

$ -> 
  grid = new Grid "screen", 4, 4
  grid.live 5, 5
  grid.live 5, 6
  grid.live 5, 7
  grid.live 4, 7
  grid.live 3, 6

  grid.live 95, 98
  grid.live 96, 98
  grid.live 97, 98
  
  game = new GameLoop 80, grid
  #game.start()

  grid.buildPotentialStateChanging()
  console.log grid.potentialStateChanging

