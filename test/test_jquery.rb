class TestjQuery < Test::Unit::TestCase

  def test_0
    js = "jQuery.extend({a: 1});"
    data = RjsTags.test(js, :libraries => ["Common", "JQuery"])
    assert_equal("a\tkind:Number\tscope:.jQuery\n", data)
  end

  def test_1
    js = "jQuery.extend(z, {a: 1});"
    data = RjsTags.test(js, :libraries => ["Common", "JQuery"])
    assert_equal("a\tkind:Number\tscope:.z\n", data)
  end

  def test_2
    js = "(function() { var jQuery = function(){}; jQuery.extend({a: function(){}}); });"
    data = RjsTags.test(js, :libraries => ["Common", "JQuery"])
    assert_equal("CLOSURE_1\tkind:Function\tscope:
CLOSURE_2\tkind:Function\tscope:::CLOSURE_1
CLOSURE_3\tkind:Function\tscope:::CLOSURE_1.CLOSURE_2
a\tkind:CLOSURE_1.jQuery::CLOSURE_3\tscope:.CLOSURE_2
jQuery\tkind:CLOSURE_1::CLOSURE_2\tscope:::CLOSURE_1\n", data)
  end

  def test_3
    js = "jQuery.fn.extend({ a: 1});"
    data = RjsTags.test(js, :libraries => ["Common", "JQuery"])
    assert_equal("a\tkind:Number\tscope:.jQuery.fn\n", data)
  end

end

