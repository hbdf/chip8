require_relative 'cpu'
require_relative 'screen'
require_relative 'memory'
require 'ruby2d'

bytecode = File.open("pong") { |f| f.read }.unpack('C*')

screen = Chip8::Screen.new

memory = Chip8::Memory.new
memory.load(bytecode)

keyboard = Array.new(0xF, 0x0)

cpu = Chip8::Cpu.new(memory, screen, keyboard)

on :key_down do |event|
  (0x0..0xF).each do |key|
    keyboard[key] = 1 if event.key == key.to_s(16)
  end
end

on :key_up do |event|
  (0x0..0xF).each do |key|
    keyboard[key] = 0 if event.key == key.to_s(16)
  end
end

update do
  cpu.run_cycle
  screen.update
end

show
