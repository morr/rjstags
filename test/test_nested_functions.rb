class TestNestedFunctions < Test::Unit::TestCase

  def test_0
    js = "(function(){ var d = function(){ var e = a; }; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
d\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1
e\tkind:a\tscope:::CLOSURE_1::CLOSURE_2\n", data)
  end

  def test_1
    js = "(function(){ var a;var d = function(){ var e = a; }; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
a\tkind:Object\tscope:::CLOSURE_1
d\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1
e\tkind:CLOSURE_1::a\tscope:::CLOSURE_1::CLOSURE_2\n", data)
  end

  def test_2
    js = "(function(){ function d(){ }; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
d\tkind:Function\tscope:::CLOSURE_1\n", data)
  end

  def test_3
    js = "(function(){ (function(){ })() })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1\n", data)
  end

end

