class TestResolveKind < Test::Unit::TestCase

  def test_0
    js = "var a; (function(){ var b = a; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:Object\tscope:
b\tkind:a\tscope:::CLOSURE_1\n", data)
  end

  def test_1
    js = "(function(){var d = function(){ var a = d; }; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
a\tkind:CLOSURE_1::d\tscope:::CLOSURE_1::CLOSURE_2
d\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1\n", data)
  end

  def test_2
    js = "(function(){var d = function(){ this.a = d; }; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
a\tkind:CLOSURE_1::d\tscope:::CLOSURE_1.CLOSURE_2
d\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1\n", data)
  end

  def test_3
    js = "(function(){ var d = function(){ a = d; }; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
a\tkind:CLOSURE_1::d\tscope:
d\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1\n", data)
  end

  def test_4
    js = "(function(){ a = '1'; a = '2'; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:String\tscope:\n", data)
  end

end
