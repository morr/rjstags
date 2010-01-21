class TestObjectInit < Test::Unit::TestCase

  def test_0
    js = "var A = { a: {b: 0} }"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Object\tscope:
a\tkind:Object\tscope:.A
b\tkind:Number\tscope:.A.a\n", data)
  end

  def test_1
    js = "(function(){ var a = {'b': 1}; })();"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:Object\tscope:::CLOSURE_1
b\tkind:Number\tscope:::CLOSURE_1.a\n", data)
  end

  def test_2
    js = "var A = { a: function(){ } }"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Object\tscope:
CLOSURE_1\tkind:Function\tscope:.A
a\tkind:A::CLOSURE_1\tscope:.A\n", data)
  end

end

