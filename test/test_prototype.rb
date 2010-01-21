class TestPrototype < Test::Unit::TestCase

  def test_0
    js = "var A = function() { }; A.prototype = { 'c': true };"
    data = RjsTags.test(js)
    assert_equal("A\tkind:CLOSURE_1\tscope:
CLOSURE_1\tkind:Function\tscope:
c\tkind:Boolean\tscope:.CLOSURE_1\n", data)
  end

end
