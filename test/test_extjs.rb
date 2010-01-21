class TestExtJS < Test::Unit::TestCase

  def test_0
    js = "var a = Ext.extend(z, {b: 1});"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("a\tkind:z\tscope:
b\tkind:Number\tscope:.a\n", data)
  end

  def test_1
    js = "a = Ext.extend(z, {b: 1});"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("a\tkind:z\tscope:
b\tkind:Number\tscope:.a\n", data)
  end

  def test_2
    js = "Ext.extend(A, B, { a: 1 });"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("A\tkind:B\tscope:
a\tkind:Number\tscope:.A\n", data)
  end

  def test_3
    js = "var a = Ext.extend(z, {b: {c: 5}});"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("a\tkind:z\tscope:
b\tkind:Object\tscope:.a
c\tkind:Number\tscope:.a.b\n", data)
  end

  def test_4
    js = "Ext.apply(A, { a: 1 });"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("a\tkind:Number\tscope:.A\n", data)
  end

  def test_5
    js = "Ext.apply(A, function(){ return { a: 1 }; }());"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("a\tkind:Number\tscope:.A\n", data)
  end

  def test_6
    js = "A = Ext.apply(B, { a: 1 });"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("A\tkind:B\tscope:
a\tkind:Number\tscope:.B\n", data)
  end

  def test_7
    js = "var A = Ext.apply(B, { a: 1 });"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("A\tkind:B\tscope:
a\tkind:Number\tscope:.B\n", data)
  end

  def test_8
    js = "A = Ext.apply(new B(), { a: 1 });"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("A\tkind:B\tscope:
a\tkind:Number\tscope:.A\n", data)
  end

  def test_9
    js = "var A = Ext.apply(new B(), { a: 1 });"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("A\tkind:B\tscope:
a\tkind:Number\tscope:.A\n", data)
  end

  def test_10
    js = "Ext.A = function(){ this.a = []; }; Ext.extend(Ext.A, Ext.B, {b:1});"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("A\tkind:CLOSURE_1\tscope:.Ext
CLOSURE_1\tkind:Ext.B\tscope:
a\tkind:Array\tscope:.Ext.B
b\tkind:Number\tscope:.Ext.A\n", data)
  end

  def test_11
    js = "Ext.applyIf(A, { a: 1 });"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("a\tkind:Number\tscope:.A\n", data)
  end

  def test_12
    js = "(function(){Ext.applyIf(A, { a: 1 });})();"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:Number\tscope:.A\n", data)
  end

  def test_13
    js = "Ext.A.addMethods({ a : function(){ } });"
    data = RjsTags.test(js, :libraries => ["Common", "ExtJS"])
    assert_equal("CLOSURE_1\tkind:Function\tscope:
a\tkind:CLOSURE_1\tscope:.Ext.A\n", data)
  end

end
