class TestResolveScope < Test::Unit::TestCase

  def test_0
    js = "(function(){ a = true; })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:Boolean\tscope:\n", data)
  end

  def test_1
    js = "(function(){ (function(){ a = true; }) })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
a\tkind:Boolean\tscope:\n", data)
  end

  def test_2
    js = "(function(){ var a; (function(){ a = true; }) })()"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
a\tkind:Boolean\tscope:::CLOSURE_1\n", data)
  end

  def test_3
    js = "(function() { var t = {}; t.a = z.c; })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:z.c\tscope:::CLOSURE_1.t
t\tkind:Object\tscope:::CLOSURE_1\n", data)
  end

  def test_4
    js = "var jQuery = function() { }; jQuery.fn = { };"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
fn\tkind:Object\tscope:.CLOSURE_1
jQuery\tkind:CLOSURE_1\tscope:\n", data)
  end

  def test_5
    js = "(function(){ var jQuery = function() { }; jQuery.fn = { }; })();"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
fn\tkind:Object\tscope:::CLOSURE_1.CLOSURE_2
jQuery\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1\n", data)
  end

  def test_6
    js = "(function(){ var A = function() { }; A.b = { c: '5' }; })();"
    data = RjsTags.test(js)
    assert_equal("A\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1
CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
b\tkind:Object\tscope:::CLOSURE_1.CLOSURE_2
c\tkind:String\tscope:::CLOSURE_1.CLOSURE_2.b\n", data)
  end

  def test_7
    js = "var A = function(){}; A.a = {'b': 5};"
    data = RjsTags.test(js)
    assert_equal("A\tkind:CLOSURE_1\tscope:
CLOSURE_1\tkind:Function\tscope:
a\tkind:Object\tscope:.CLOSURE_1
b\tkind:Number\tscope:.CLOSURE_1.a\n", data)
  end

  def test_8
    js = "(function(){ A.a = B.b; })();"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:B.b\tscope:.A\n", data)
  end

  def test_9
    js = "(function(){ A = {a : 1 }; })();"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Object\tscope:
CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:.A\n", data)
  end

  def test_10
    js = "(function(){ var A = {a : 1 }; })();"
    data = RjsTags.test(js)
    assert_equal("A\tkind:Object\tscope:::CLOSURE_1
CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:::CLOSURE_1.A\n", data)
  end

  def test_11
    js = "(function(){ A.B = { a : 1 }; })();"
    data = RjsTags.test(js)
    assert_equal("B\tkind:Object\tscope:.A
CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:.A.B\n", data)
  end

end
