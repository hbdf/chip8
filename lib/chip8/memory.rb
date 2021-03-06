module Chip8
  class Memory
    FONTSET = [
      0xF0, 0x90, 0x90, 0x90, 0xF0,   # 0
      0x20, 0x60, 0x20, 0x20, 0x70,   # 1
      0xF0, 0x10, 0xF0, 0x80, 0xF0,   # 2
      0xF0, 0x10, 0xF0, 0x10, 0xF0,   # 3
      0x90, 0x90, 0xF0, 0x10, 0x10,   # 4
      0xF0, 0x80, 0xF0, 0x10, 0xF0,   # 5
      0xF0, 0x80, 0xF0, 0x90, 0xF0,   # 6
      0xF0, 0x10, 0x20, 0x40, 0x40,   # 7
      0xF0, 0x90, 0xF0, 0x90, 0xF0,   # 8
      0xF0, 0x90, 0xF0, 0x10, 0xF0,   # 9
      0xF0, 0x90, 0xF0, 0x90, 0x90,   # A
      0xE0, 0x90, 0xE0, 0x90, 0xE0,   # B
      0xF0, 0x80, 0x80, 0x80, 0xF0,   # C
      0xE0, 0x90, 0x90, 0x90, 0xE0,   # D
      0xF0, 0x80, 0xF0, 0x80, 0xF0,   # E
      0xF0, 0x80, 0xF0, 0x80, 0x80    # F
    ]

    def initialize
      @memo = Array.new(0x1000, 0x0)
      load_font_set
    end

    def load_font_set
      FONTSET.each_with_index do |v, i|
        @memo[i] = v
      end
    end

    def load(bytecode)
      bytecode.each_with_index do |v, i|
        @memo[0x200 + i] = v
      end
    end
    def [](address)
      @memo[address]
    end

    def []=(address, value)
      @memo[address] = value
    end
  end
end
