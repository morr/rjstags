class TestAssign < Test::Unit::TestCase

  def test_0
    js = "a = a || document;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:\n", data)
  end

  def test_1
    js = "var t = {}; t.a = z.c;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:z.c\tscope:.t
t\tkind:Object\tscope:\n", data)
  end

  def test_2
    js = "(function() { var t = {}; t.a = z.c; })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:z.c\tscope:::CLOSURE_1.t
t\tkind:Object\tscope:::CLOSURE_1\n", data)
  end

  def test_3
    js = "(function(){ var a = b = function(){} })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
a\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1
b\tkind:CLOSURE_1::CLOSURE_2\tscope:\n", data)
  end

  def test_4
    js = "(function(){ this.a = new string(); })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:string\tscope:.CLOSURE_1\n", data)
  end

  def test_5
    js = "var A = new (function(){  })();"
    data = RjsTags.test(js)
    assert_equal("A\tkind:CLOSURE_1\tscope:
CLOSURE_1\tkind:Function\tscope:\n", data)
  end

  def test_6
    js = "A = new (function(){  })();"
    data = RjsTags.test(js)
    assert_equal("A\tkind:CLOSURE_1\tscope:
CLOSURE_1\tkind:Function\tscope:\n", data)
  end

end
