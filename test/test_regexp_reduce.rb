class TestRegexpReduce < Test::Unit::TestCase

  def test_0
    js = "if(asd){}"
    data = RjsTags.filter_code(js)
    assert_equal(";", data)
  end

  def test_1
    js = "for(asd){}"
    data = RjsTags.filter_code(js)
    assert_equal(";", data)
  end

  def test_2
    js = "while(fdsfsd){}"
    data = RjsTags.filter_code(js)
    assert_equal(";", data)
  end

  def test_3
    js = "if(fdsfsd){} else{test;}"
    data = RjsTags.filter_code(js)
    assert_equal(";;", data)
  end

  def test_4
    js = "while(asd){ if(asd){} }"
    data = RjsTags.filter_code(js)
    assert_equal(";", data)
  end

  def test_5
    js = "for(asd){ if(asd){}; if(asd){}; }"
    data = RjsTags.filter_code(js)
    assert_equal(";", data)
  end

  def test_6
    js = "if(asd) test;"
    data = RjsTags.filter_code(js)
    assert_equal("if(asd) test;", data)
  end

  def test_7
    js = "while(asd) test;"
    data = RjsTags.filter_code(js)
    assert_equal("while(asd) test;", data)
  end

  def test_8
    js = "while(asd) if(asdas) { test; }"
    data = RjsTags.filter_code(js)
    assert_equal("while(asd);", data)
  end

  def test_9
    js = "while(a(s)d) { test; }"
    data = RjsTags.filter_code(js)
    assert_equal(";", data)
  end

  def test_10
    js = "while(a)(d) { test; }"
    data = RjsTags.filter_code(js)
    assert_equal("while(a)(d) { test; }", data)
  end

  def test_11
    js = "while(a()d()asd) { test; }"
    data = RjsTags.filter_code(js)
    assert_equal(";", data)
  end

  def test_12
    js = "/* test */"
    data = RjsTags.filter_code(js)
    assert_equal("", data)
  end

  def test_13
    js = "   /* test */"
    data = RjsTags.filter_code(js)
    assert_equal("", data)
  end

  def test_14
    js = "while(aasd) { if(asd){ if(zxc) { } } }"
    data = RjsTags.filter_code(js)
    assert_equal(";", data)
  end

end

