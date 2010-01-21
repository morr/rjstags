class TestPrototypeJS < Test::Unit::TestCase

  def test_0
    js = "Object.extend(A, {b: 1});"
    data = RjsTags.test(js, :libraries => ["Common", "Prototype"])
    assert_equal("b\tkind:Number\tscope:.A\n", data)
  end

  def test_1
    js = "Object.extend(String, (function() { return { gsub: 1 }; })());"
    data = RjsTags.test(js, :libraries => ["Common", "Prototype"])
    assert_equal("CLOSURE_1\tkind:Function\tscope:
gsub\tkind:Number\tscope:.String\n", data)
  end

  def test_2
    js = "Object.extend(String.prototype, (function() { return { gsub: 1 }; })());"
    data = RjsTags.test(js, :libraries => ["Common", "Prototype"])
    assert_equal("CLOSURE_1\tkind:Function\tscope:
gsub\tkind:Number\tscope:.String.prototype\n", data)
  end

end
