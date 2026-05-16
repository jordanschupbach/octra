require "minitest/autorun"

require "octruby"

class TestOctra < Minitest::Test
  def test_loads_and_calls_hello
    assert Octra.respond_to?(:hello)
    Octra.hello
  end

  def test_can_allocate_and_free_pair
    pair = Octra::DPair.new(1.0, 2.0)
    assert pair
    pair.delete if pair.respond_to?(:delete)
  end
end

