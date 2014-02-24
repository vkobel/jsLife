
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
    @activeCells = {}
    @potentialStateChanging = {}

    @counter = 0
  
  keyFromCoords: (x, y) ->
    (parseInt(x) << 16) + parseInt(y)

  coordsFromKey: (key) ->
    [key >> 16, key & 0xFFFF]

  draw: (x, y, color) ->
    super x * @sizeX, y * @sizeY, @sizeX, @sizeY, color ? "#111"

  buildPotentialStateChanging: () ->
    
    @potentialStateChanging = {}

    for key of @activeCells
      coords = @coordsFromKey key
      for [ax, ay] in @getAdjacentCoords(coords, true)
        akey = @keyFromCoords ax, ay
        if @potentialStateChanging[akey]?
          weight = ++@potentialStateChanging[akey]
        else
          @potentialStateChanging[akey] = 1
          #@draw ax, ay, "#0F0"

  live: (x, y) ->
    @draw x, y, "#FAB23E"
    @activeCells[@keyFromCoords x, y] = true

  die: (x, y) ->
    @draw x, y, "#111"
    delete @activeCells[@keyFromCoords x, y]

  isAlive: (matrix, key) ->
    matrix[key]?

  neighboursCount: (matrix, x, y) ->
    nb = 0
    for [ax, ay] in @getAdjacentCoords([x, y], false)
      nb++ if matrix[@keyFromCoords ax, ay]?
    nb

  getAdjacentCoords: (coords, itself) ->
    if itself == true
      [[coords[0]-1, coords[1]-1], [coords[0], coords[1]-1], [coords[0]+1, coords[1]-1],
       [coords[0]-1, coords[1]  ], [coords[0], coords[1]],   [coords[0]+1, coords[1]  ],
       [coords[0]-1, coords[1]+1], [coords[0], coords[1]+1], [coords[0]+1, coords[1]+1]]
    else
      [[coords[0]-1, coords[1]-1], [coords[0], coords[1]-1], [coords[0]+1, coords[1]-1],
       [coords[0]-1, coords[1]  ],                           [coords[0]+1, coords[1]  ],
       [coords[0]-1, coords[1]+1], [coords[0], coords[1]+1], [coords[0]+1, coords[1]+1]]



class GameLoop
  constructor: (fps, @grid) ->
    @dur = 1000 / fps

  compute: =>
    
    @grid.buildPotentialStateChanging()
    tmp = $.extend {}, @grid.activeCells # make copy of the array

    for key, weight of @grid.potentialStateChanging
      
      [x, y] = @grid.coordsFromKey key
      count = @grid.neighboursCount tmp, x, y

      if @grid.isAlive tmp, key
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
  grid = new Grid "screen", 3, 3
  grid.live 5, 5
  grid.live 5, 6
  grid.live 5, 7
  grid.live 4, 7
  grid.live 3, 6
  grid.live 4, 7

  grid.live 95, 98
  grid.live 96, 98
  grid.live 97, 98
  
  game = new GameLoop 40, grid

  game.start()

