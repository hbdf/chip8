module Chip8

  #TODO: Think about this
  class Screen
    WIDTH = 64
    HEIGHT = 32
    SCALE = 10

    def initialize
      Window.set background: 'black', title: 'HF Chip8', width: WIDTH * SCALE, height: HEIGHT * SCALE
      # pixels matrix
      @pixel_matrix = Array.new
      @screen = Array.new
      (0..(HEIGHT)).each do |i|
        tmp = Array.new
        clr = Array.new
        (0..(WIDTH)).each do |j|
          tmp.push(Square.new(x: j * SCALE, y: i * SCALE, size: SCALE, color: 'white'))
          clr.push(0)
        end
        @screen.push(tmp)
        @pixel_matrix.push(clr)
      end
    end

    def clear
      (0..(HEIGHT)).each do |j|
        (0..(WIDTH)).each do |i|
          set_pixel(i, j, 0x0)
        end
      end
    end

    def get_pixel(i, j)
      @pixel_matrix[j % 32][i % 64]
    end

    def set_pixel(i, j, val)
      @pixel_matrix[j % 32][i % 64] = val
    end

    def update
      matrix = @pixel_matrix
      (0..(HEIGHT)).each do |j|
        (0..(WIDTH)).each do |i|
          color = matrix[j][i] == 0x1 ?  'white' : 'black'
          @screen[j][i].color = color
        end
      end
    end
  end
end
