class TestDot < Test::Unit::TestCase

 def test_0
   js = "var a = b.c;"
   data = RjsTags.test(js)
   assert_equal("a\tkind:b.c\tscope:\n", data)
 end

 def test_0
   js = "a.b = b.c;"
   data = RjsTags.test(js)
   assert_equal("b\tkind:b.c\tscope:.a\n", data)
 end

end
