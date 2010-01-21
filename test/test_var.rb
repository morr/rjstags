class TestVar < Test::Unit::TestCase

  def test_var_a
    js = "var a;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:\n", data)
  end

  def test_var_a_b
    js = "var a,b;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:
b\tkind:Object\tscope:\n", data)
  end

  def test_a_eq_a
    js = "var a=a;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:a\tscope:\n", data)
  end

  def test_a_eq_b
    js = "var a=b;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:b\tscope:\n", data)
  end

  def test_a_eq_array
    js = "var a = [];;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Array\tscope:\n", data)
  end

  def test_a_eq_str
    js = "var a='5';"
    data = RjsTags.test(js)
    assert_equal("a\tkind:String\tscope:\n", data)
  end

  def test_a_eq_true
    js = "var a=true;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Boolean\tscope:\n", data)
  end

  def test_a_eq_false
    js = "var a=false;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Boolean\tscope:\n", data)
  end

  def test_a_eq_regexp
    js = "var a=/test/;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:RegExp\tscope:\n", data)
  end

  def test_a_eq_obj
    js = "var a={};"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:\n", data)
  end

  def test_var_a_eq_bc
    js = "var a = b.c;"
    data = RjsTags.test(js)
    assert_equal("a\tkind:b.c\tscope:\n", data)
  end

  def test_var_a_runtime
    js = "var a = quickExpr.exec( selector );"
    data = RjsTags.test(js)
    assert_equal("a\tkind:Object\tscope:\n", data)
  end

end
