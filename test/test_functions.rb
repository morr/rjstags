class TestFunctions < Test::Unit::TestCase

  def test_0
    js = "(function(){  })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:\n", data)
  end

  def test_1
    js = "function A(){  }"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Function\tscope:\n", data)
  end

  def test_2
    js = "var A = function(){  }"
    data = RjsTags.test(js)
    assert_equal("A\tkind:CLOSURE_1\tscope:
CLOSURE_1\tkind:Function\tscope:\n", data)
  end

  def test_3
    js = "A = function(){ return { a: 1 }; }()"
    data = RjsTags.test(js)
    assert_equal("A\tkind:CLOSURE_1\tscope:
CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:.CLOSURE_1\n", data)
  end

  def test_4
    js = "var A = function(){ return { a: 1 }; }()"
    data = RjsTags.test(js)
    assert_equal("A\tkind:CLOSURE_1\tscope:
CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:.CLOSURE_1\n", data)
  end
end


