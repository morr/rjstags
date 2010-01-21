class TestExclude < Test::Unit::TestCase

  def test_0
    js = "(function(){ var id = 'script' + (new Date).getTime(); })();"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
id\tkind:Object\tscope:::CLOSURE_1\n", data)
  end

  def test_1
    js = "(function(){ var a = 'script' - (new Date).getTime(); })();"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:Object\tscope:::CLOSURE_1\n", data)
  end

  def test_2
    js = "function A() { var a = (b)[1]; }"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Function\tscope:
a\tkind:Object\tscope:::A\n", data)
  end

  def test_3
    js = "function A(){ var B = function(){ }.extend(this); };"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Function\tscope:
B\tkind:Object\tscope:::A\n", data)
  end

  def test_4
    js = "function A(){ var a = (1) ? 2 : 2; }"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Function\tscope:
a\tkind:Object\tscope:::A\n", data)
  end

  def test_5
    js = "function A(){ var a = typeof b; }"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Function\tscope:
a\tkind:Object\tscope:::A\n", data)
  end

  def test_6
    js = "function A(){ var a = c instanceof b; }"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Function\tscope:
a\tkind:Object\tscope:::A\n", data)
  end

end
