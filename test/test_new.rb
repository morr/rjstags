class TestNew < Test::Unit::TestCase

  def test_0
    js = "var a = new String()"
    data = RjsTags.test(js)
    assert_equal("a\tkind:String\tscope:\n", data)
  end

  def test_1
    js = "var a = new String('param')"
    data = RjsTags.test(js)
    assert_equal("a\tkind:String\tscope:\n", data)
  end

  def test_2
    js = "var a = new BlaBlaBla()"
    data = RjsTags.test(js)
    assert_equal("a\tkind:BlaBlaBla\tscope:\n", data)
  end

  def test_3
    js = "var a = new BlaBlaBla(param1,param2)"
    data = RjsTags.test(js)
    assert_equal("a\tkind:BlaBlaBla\tscope:\n", data)
  end

end
