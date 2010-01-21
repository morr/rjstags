module Narcissus
  class Node
    #
    # return full node name
    #
    def resolve_name
      name = ""

      if @type == CONSTS["DOT"]
        chldrn = self.get_children
        name = chldrn[0].resolve_name+"."+chldrn[1].resolve_name
      else # INDENTIFIER
        name = @name || (@value.class != Node ? @value : "")
      end

      name = "" if name == nil
      name = name.to_s(10) if name.class == Fixnum
      name = name.to_s if name.class != String
      name.gsub!(/^'|^"|'$|"$/, "")
      return name
    end

    #
    # return all node children
    #
    def get_children(node=self)
      children = []
      attrs = [@type, @value, @lineno, @start, @end, @tokenizer, @initializer, @name, @params, @funDecls, @varDecls, @body, @functionForm, @assignOp, @expression, @condition, @thenPart, @elsePart, @readOnly, @isLoop, @setup, @postfix, @update, @exception, @object, @iterator, @varDecl, @label, @target, @tryBlock, @catchClauses, @varName, @guard, @block, @discriminant, @cases, @defaultIndex, @caseLabel, @statements, @statement]

      @children.length.times do |i|
        children.push(@children[i]) if @children[i] != @children and @children[i].class == Node
      end

      attrs.length.times do |attr|
        children.push(attrs[attr]) if attrs[attr].class == Node and attrs[attr] != node
      end

      return children
    end
  end
end


class SyntaxTree
  TOKENS = Narcissus::TOKENS
  CONSTS = Narcissus::CONSTS
  OPERATOR_TYPE_NAMES = Narcissus::OPERATOR_TYPE_NAMES

  CONSTS["RUNTIME"] = 999
  TOKENS[CONSTS["RUNTIME"]] = "RUNTIME"

  EXCLUDE_NODES = [
    CONSTS["INSTANCEOF"],
    CONSTS["TYPEOF"],
    CONSTS["NULL"],
    CONSTS["CONDITIONAL"],
    CONSTS["WHILE"],
    CONSTS["FOR"],
    CONSTS["FOR_IN"],
    CONSTS["THIS"],
    CONSTS["IF"],
    #CONSTS["RETURN"],
  ]
  BUILDIN_TYPES = ["Number", "String", "RegExp", "Boolean", "Object", "Function"]
  SIMPLE_TYPES = ["Number", "String", "RegExp", "Boolean"]
  CTAGS_TYPES = {
    "RUNTIME" => "Object", # RUNTIME means that type cannot be specified in code parse phase
    "NUMBER" => "Number",
    "OBJECT" => "Object",
    "FUNCTION" => "Function",
    "STRING" => "String",
    "REGEXP" => "RegExp",
    "ARRAY_INIT" => "Array",
    "OBJECT_INIT" => "Object",
    "TRUE" => "Boolean",
    "FALSE" => "Boolean",
    "true" => "Boolean",
    "false" => "Boolean",
    "FUNCTION" => "Function",
    "function" => "Function"
  }

  #
  # TreeItem class
  #
  class TreeItem
    attr_accessor :index
    attr_accessor :kind
    attr_accessor :lineno
    attr_accessor :name
    attr_accessor :reduced_name
    attr_accessor :nodes
    attr_accessor :parent
    attr_accessor :scope
    attr_accessor :skip
    attr_accessor :type

    #
    # constructor
    #
    def initialize(node, parent=nil)
      @index  = 0
      @kind   = nil
      @lineno = 0
      @name   = node.resolve_name
      @nodes  = []
      @parent = parent
      @scope  = ""
      @skip   = false
      @type   = node.type

      item = nil
      node.get_children.each do |node|
        item = TreeItem.new(node, self)
        item.index = @nodes.length
        @nodes << item
      end
    end

    #
    # print node
    #
    def dump
      offset = ""
      par = @parent
      while par
        par = par.parent
        offset += " "
      end
      puts offset+(@name == "" ? "-=NONE=-" : @name)+"\ttype("+TOKENS[@type]+")\tkind("+(@kind ? @kind : "")+")\tscope("+@scope+")\tline("+@lineno.to_s+")"
    end

    #
    # print content and terminate execution
    #
    def die
      puts "\n\n"
      self.dump
      puts "\n\n"
      exit
    end

  end

  attr_accessor :data
  attr_accessor :resolved_scopes

  #
  # constructor
  #
  def initialize(node, parsers)
    @tree = TreeItem.new(node)
    @last_scope_id = $debug || $TEST ? 0 : Time.now.to_i
    @resolved_scopes = {}
    @data = {}
    @parsers = parsers

    puts "\n\n-=FIRST RUN=-\n\n" if $debug
    self.process_first(@tree)
    puts "\n-=SECOND RUN=-\n\n" if $debug
    self.process_second(@tree)
    #puts "\n-=THIRD RUN=-\n\n" if $debug
    self.process_third(@tree)
    puts "\n-=FOURTH RUN=-\n\n" if $debug
    self.process_fourth(@tree)
  end

  #
  # init new closure and return its name
  #
  def new_closure
    @last_scope_id += 1
    "CLOSURE_"+@last_scope_id.to_s
  end

  #
  # get output for tests
  #
  def get_test
    output = []
    @data.sort {|a,b| (a[1][:name] <=> b[1][:name]) == 0 ? a[1][:scope] <=> b[1][:scope] : a[1][:name] <=> b[1][:name] }.each do |name,node|
      output << "#{node[:name]}\tkind:#{node[:kind]}\tscope:#{node[:scope]}\n"
    end
    output.join("")
  end

  #
  # get output
  #
  def get_tags
    output = []
    #@@data.sort {|a,b| (a[1][:name] <=> b[1][:name]) == 0 ? a[1][:scope] <=> b[1][:scope] : a[1][:name] <=> b[1][:name] }.each do |name,node|
    @data.each do |name,node|
      output << "#{node[:name]}\t#{node[:filename]}\t#{node[:line]}\tkind:#{node[:kind]}\tscope:#{node[:scope]}\tlanguage:js\n"
    end
    output
  end

  #
  # set nodes scope
  #
  def process_first(node)
    return if node.skip

    node.dump if $debug
    @parsers.each {|parser| parser.process_first(node, self) } if node.parent && !node.skip
    node.dump if $debug

    return if node.skip
    node.nodes.each do |item|
      self.process_first(item)
    end

  end

  #
  # set nodes kind
  #
  def process_second(node)
    return if node.skip
    node.nodes.each do |item|
      self.process_second(item)
    end

    node.dump if $debug
    @parsers.each {|parser| parser.process_second(node, self) } if node.parent && !node.skip
    node.dump if $debug
  end

  #
  # add nodes to @data hash
  #
  def process_third(node)
    return if node.skip

    @parsers.each {|parser| parser.process_third(node, self) } if node.parent && node.kind && !node.skip
    return if node.skip
    node.nodes.each do |item|
      self.process_third(item)
    end

  end

  #
  # finalize @data hash
  #
  def process_fourth(node)
    return if node.skip

    @parsers.each {|parser| parser.process_fourth(node, self) } if node.parent && node.kind && !node.skip
    node.dump if $debug

    return if node.skip
    node.nodes.each do |item|
      self.process_fourth(item)
    end

  end
end
