require 'ruby2d'

set background: 'navy'
set fps_cap: 20

# width = 640 / 20 = 32
# height = 480 / 20 = 24
GRID_SIZE = 20
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE

class Snake
    attr_writer :direction

    def initialize
        @positions = [ [2, 0], [2, 1], [2, 2], [2, 3] ]
        @direction = 'down'
        @growing = false
    end

    def draw 
        @positions.each do |p|
            Square.new(x: p[0] * GRID_SIZE, y: p[1] * GRID_SIZE, size: GRID_SIZE - 1, color: 'green')
        end
    end

    def move 

        if !@growing
            @positions.shift
        end

        case @direction 
        when 'down'
            @positions.push(new_coords(head[0], head[1] + 1))
        when 'up'
            @positions.push(new_coords(head[0], head[1] - 1))
        when 'left'
            @positions.push(new_coords(head[0] -1 , head[1]))
        when 'right'
            @positions.push(new_coords(head[0] + 1, head[1]))
        end
        @growing = false
    end

    def can_change_direction_to?(new_direction)
        case @direction
        when 'up' then new_direction != 'down'
        when 'down' then new_direction != 'up'
        when 'left' then new_direction != 'right'
        when 'right' then new_direction != 'left'
        end
    end

    def x
        head[0]
    end

    def y
        head[1]
    end

    def grow
        @growing = true
    end

    def hit_itself?
        @positions.uniq.length != @positions.length
    end

    private

    def new_coords(x, y)
        [x % GRID_WIDTH, y % GRID_WIDTH]
    end

    def head
        @positions.last
    end
end

class Game 
    def initialize
        @score = 0
        @food_x = rand(GRID_WIDTH)
        @food_y = rand(GRID_HEIGHT)
        @finished = false
    end

    def draw 
        unless finished?
            Square.new(x: @food_x * GRID_SIZE, y: @food_y * GRID_SIZE, size: GRID_SIZE, color: 'red')
        end
        Text.new(text_message, color: "white", x: 10, y: 10, size: 25)
    end

    def snake_hit_food?(x, y)
        @food_x == x && @food_y == y
    end

    def record_hit
        @score += 1
        @food_x = rand(GRID_WIDTH)
        @food_y = rand(GRID_HEIGHT)
    end

    def finish
        @finished = true
    end

    def finished?
        @finished
    end

    private
    def text_message
        if finished?
            "Game over, your score: #{@score}. Press 'R' to restart."
        else
            "Score: #{@score}"
        end
    end
end

snake = Snake.new
game = Game.new

update do
    clear

    unless game.finished?
    snake.move
    end
    snake.draw
    game.draw

    if game.snake_hit_food?(snake.x, snake.y)
        game.record_hit
        snake.grow
    end

    if snake.hit_itself?
        game.finish
    end
end

on :key_down do |e|
    if ['up','down','left','right'].include?(e.key)
        if snake.can_change_direction_to?(e.key)
            snake.direction = e.key
        end
    elsif e.key == 'r'
        snake = Snake.new
        game = Game.new
    end
end

show