class TestReturn < Test::Unit::TestCase

  def test_1
    js = "var A = (function(){ return { a: 1} })();"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Object\tscope:
CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:.A\n", data)
  end

  def test_2
    js = "A = (function(){ return { a: 1} })();"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Object\tscope:
CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:.A\n", data)
  end

end
