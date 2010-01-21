class TestWindow < Test::Unit::TestCase

  def test_0
    js = "window.a = 5;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Number\tscope:\n", data)
  end

  def test_1
    js = "window.a.b = 5;"
    data = RjsTags.test(js)
    assert_equal("b\tkind:Number\tscope:.a\n", data)
  end

  def test_2
    js = "(function(){ window.a = 5; })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:\n", data)
  end

  def test_3
    js = "(function(){ var d = function(){ window.d = 5; }; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
d\tkind:Number\tscope:
d\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1\n", data)
  end

  def test_4
    js = "(function(){ var a = window.a; })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:a\tscope:::CLOSURE_1\n", data)
  end


end
