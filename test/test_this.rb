class TestThis < Test::Unit::TestCase

  def test_0
    js = "(function(){ this.a = 5; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:.CLOSURE_1\n", data)
  end

  def test_1
    js = "function A(){ this.a = 5; }"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Function\tscope:
a\tkind:Number\tscope:.A\n", data)
  end

  def test_2
    js = "(function(){ var d = function(){ this.c = 5; }; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
c\tkind:Number\tscope:::CLOSURE_1.CLOSURE_2
d\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1\n", data)
  end

  def test_3
    js = "var A = { B: function() { var a = {}; a.b = this.c } };"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Object\tscope:
B\tkind:A::CLOSURE_1\tscope:.A
CLOSURE_1\tkind:Function\tscope:.A
a\tkind:Object\tscope:.A::CLOSURE_1
b\tkind:CLOSURE_1.c\tscope:.A::CLOSURE_1.a\n", data)
  end

  def test_4
    js = "(function(){ var a = this; })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:CLOSURE_1\tscope:::CLOSURE_1\n", data)
  end

  def test_5
    js = "(function(){ a = this; })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:CLOSURE_1\tscope:\n", data)
  end

  def test_6
    js = "(function(){ (function() { a = this; }) })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
a\tkind:CLOSURE_1::CLOSURE_2\tscope:\n", data)
  end

end
