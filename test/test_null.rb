class TestNULL < Test::Unit::TestCase

  def test_0
    js = "var a = function() { b = null; }"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:CLOSURE_1\tscope:
b\tkind:Object\tscope:\n", data)
  end

end

