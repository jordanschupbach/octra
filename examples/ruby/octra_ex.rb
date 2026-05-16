require "octruby"

Octra.hello

dp = Octra::DPair.new(1.0, 2.0)
puts "DPair created: #{dp.inspect}"
dp.delete if dp.respond_to?(:delete)
