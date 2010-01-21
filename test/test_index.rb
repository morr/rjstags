class TestIndex < Test::Unit::TestCase

  def test_0
    js = "a = a || document;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:\n", data)
  end

end

