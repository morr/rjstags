class TestThis < Test::Unit::TestCase

  def test_0
    js = "(function(){ var z = a ? b : c; })"
    data = RjsTags.test(js)
    assert_equal("CLOSURE_1\tkind:Function\tscope:
z\tkind:CLOSURE_1::Object\tscope:::CLOSURE_1\n", data)
  end

end

