require_relative 'memory'
require_relative 'screen'

module Chip8
  class Cpu
    attr_reader :memory, :screen, :keyboard

    def initialize(memory, screen, keyboard)
      @screen = screen
      @memory = memory
      @keyboard = keyboard
      @pc = 0x200
      @v = Array.new(0xF, 0x0)
      @i = 0
      @delay = 0
      @sound = 0
      @stack = Array.new(0xF, 0x0)
      @sp = 0
    end

    def run_cycle
      decode
      fetch
      execute
      @delay -= 1 if @delay > 0
      @sound -= 1 if @sound > 0
    end

    def decode
      @opcode = (memory[@pc] << 8) | memory[@pc + 1]
    end

    def fetch
      @code = (@opcode & 0xF000) >> 12

      # Usual values
      @nnn = @opcode & 0x0FFF
      @nn = @opcode & 0x00FF
      @n = @opcode & 0x000F

      # Registers
      @x = (@opcode & 0x0F00) >> 8
      @y = (@opcode & 0x00F0) >> 4
    end

    def execute
      @pc += 0x2

      if @opcode == 0x00EE
        @pc = @stack[@sp - 1]
        @sp -= 1
      end

      if @opcode == 0x00E0
        screen.clear
      end

      case @code
      when 0x1
        @pc = @nnn
      when 0x2
        @stack[@sp] = @pc
        @sp += 1
        @pc = @nnn
      when 0x3
        @pc += 0x2 if @v[@x] == @nn
      when 0x4
        @pc += 0x2 if @v[@x] != @nn
      when 0x5
        @pc += 0x2 if @v[@x] == @v[@y]
      when 0x6
        @v[@x] = @nn
      when 0x7
        @v[@x] = (@v[@x] + @nn) & 0xFF
      when 0x8
        case @n
        when 0x0
          @v[@x] = @v[@y]
        when 0x1
          @v[@x] |= @v[@y]
        when 0x2
          @v[@x] &= @v[@y]
        when 0x3
          @v[@x] ^= @v[@y]
        when 0x4
          @v[@x] += @v[@y]
          @v[0xF] = @v[@x] > 0xFF
          @v[@x] &= 0xFF
        when 0x5
          @v[0xF] = @v[@x] > @v[@y] ? 0x1 : 0x0
          @v[@x] = (@v[@x] - @v[@y]) & 0xFF
        when 0x6
          @v[0xF] = (@v[@x] & 0x1) ? 0x1 : 0x0
          @v[@x] = (@v[@x] >> 1) & 0xFF
        when 0x7
          @v[0xF] = (@v[@y] > @v[@x]) ? 0x1 : 0x0
          @v[@x] = (@v[@y] - @v[@x]) & 0xFF
        when 0xE
          @v[0xF] = (@v[@x] & 0x80) > 0 ? 0x1 : 0x0
          @v[@x] = (@v[@x] << 1) & 0xFF
        end
      when 0x9
        @pc += 0x2 if @v[@x] != @v[@y]
      when 0xA
        @i = @nnn
      when 0xB
        @pc = @nnn + @v[0x0]
      when 0xC
        @v[@x] = rand(0x0..0xFF) & @nn
      when 0xD
        sprites = []
        (0x0..(@n - 0x1)).each do |v|
          sprites.push(memory[@i + v])
        end

        px = @v[@x]
        py = @v[@y]
        @v[0xF] = 0x0

        sprites.each_with_index do |v, i|
          (0x0..0x7).each do |j|
            sprite_pixel = (v & (0x80 >> j)) > 0 ? 0x1 : 0x0
            current_pixel = screen.get_pixel(px + j, py + i)
            @v[0xF] |= (sprite_pixel & current_pixel)
            screen.set_pixel(px + j, py + i, sprite_pixel ^ current_pixel)
          end
        end
      when 0xE
        if @nn == 0x9E && keyboard[@v[@x]] == 1
          @pc += 0x2
        elsif @nn == 0xA1 && keyboard[@v[@x]] == 0
          @pc += 0x2
        end
      when 0xF
        case @nn
        when 0x07
          @v[@x] = @delay
        when 0x0A
          pressed = false
          (0x0..0xF).each do |i|
            if keyboard[i] != 0
              @v[i] = i
              pressed = true
            end
          end
          @pc -= 2 if !pressed
        when 0x15
          @delay = @v[@x]
        when 0x18
          @sound = @v[@x]
        when 0x1E
          @i = (@i + @v[@x]) & 0xFF
        when 0x29
          @i = (@v[@x] * 0x5) & 0xFF
        when 0x33
          memory[@i] = @v[@x] / 100
          memory[@i + 1] = (@v[@x] / 10) % 10
          memory[@i + 2] = @v[@x] % 10
        when 0x55
          (0..@x).each { |r| memory[@i + r] = @v[r] }
        when 0x65
          (0..@x).each { |r| @v[r] = memory[@i + r] }
        end
      end
    end
  end
end
