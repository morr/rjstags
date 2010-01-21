class TestHash < Test::Unit::TestCase

  def test_0
    js = "var a={'a': '5'};"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:
a\tkind:String\tscope:.a\n", data)
  end

  def test_1
    js = "var a={'b': '5'};"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:
b\tkind:String\tscope:.a\n", data)
  end

  def test_2
    js = "var a={'b': 5};"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:
b\tkind:Number\tscope:.a\n", data)
  end

  def test_3
    js = "var a={'b': {}};"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:
b\tkind:Object\tscope:.a\n", data)
  end

  def test_4
    js = "var a={'b':{},'c': {}};"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:
b\tkind:Object\tscope:.a
c\tkind:Object\tscope:.a\n", data)
  end

end
