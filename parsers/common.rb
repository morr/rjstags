class CommonParser

  #
  # set node scope
  #
  def self.process_first(node, tree)
    node.scope = node.parent ? String.new(node.parent.scope) : ""
    if SyntaxTree::EXCLUDE_NODES.include?(node.type) ||
        #(node.type == SyntaxTree::CONSTS["CALL"] && node.nodes[0].type != SyntaxTree::CONSTS["FUNCTION"] && node.parent.nodes[1] && node.parent.nodes[1].object_id == node.object_id && node.nodes[0].resolve_name != 'Ext.extend' && node.nodes[0].resolve_name != 'Ext.apply' && node.nodes[0].resolve_name != 'Ext.applyIf') ||
        (node.type == SyntaxTree::CONSTS["ASSIGN"] && node.nodes[1] && (node.nodes[1].type == SyntaxTree::CONSTS["INDEX"] || node.nodes[1].type == SyntaxTree::CONSTS["GROUP"])) ||
        (node.type == SyntaxTree::CONSTS["DOT"] && node.nodes[1] && (node.nodes[0].type == SyntaxTree::CONSTS["CALL"] || node.nodes[0].type == SyntaxTree::CONSTS["INDEX"] || node.nodes[0].type == SyntaxTree::CONSTS["GROUP"])) ||
        (SyntaxTree::OPERATOR_TYPE_NAMES[node.name] && !['{', '}', '[', ']', '(', ')', '.', ',', '=', ';', ':'].include?(node.name)) ||
        (node.type == SyntaxTree::CONSTS["RETURN"] && !(node.nodes[0] && node.nodes[0].type == SyntaxTree::CONSTS["OBJECT_INIT"] && node.parent.parent && node.parent.parent.parent && (node.parent.parent.parent.type == SyntaxTree::CONSTS["CALL"] || (node.parent.parent.parent.parent && node.parent.parent.parent.parent.type == SyntaxTree::CONSTS["CALL"]))))
      if node.type == SyntaxTree::CONSTS["THIS"]
        node.skip = true
        return
      end
      node.nodes = []
      node.type = SyntaxTree::CONSTS["RUNTIME"]
      node.kind = SyntaxTree::CTAGS_TYPES[node.type]
      node.skip = true
      return
    end

    # INDEX
    if node.type == SyntaxTree::CONSTS["INDEX"]
      # skip the whole tree if it is index with identifier
      if node.nodes[1].type == SyntaxTree::CONSTS["IDENTIFIER"] 
        node.parent.skip = true
      end
      # add new var if it isn't IDENTIFIER
      if node.nodes[1] && node.nodes[1].type != SyntaxTree::CONSTS["IDENTIFIER"]
        node.name = node.nodes[0].name+"."+node.nodes[1].name
      end
    end

    if node.type == SyntaxTree::CONSTS["DOT"]
      # prototype
      if node.name =~ /\.prototype\./
        node.name = node.name.sub(/\.prototype\./, '.')
        node.nodes[0].skip = true
        node.nodes[1].skip = true
      end
    end

    # scope
    if node.type == SyntaxTree::CONSTS["OBJECT_INIT"]
      # prototype
      if node.parent.nodes[0].name =~ /\.prototype$/ && node.parent.type == SyntaxTree::CONSTS["ASSIGN"]
        node.scope += "."+node.parent.nodes[0].name.sub(/\.prototype$/, '')
        node.parent.nodes[0].skip = true
      else
        case node.parent.type
          when SyntaxTree::CONSTS["ASSIGN"]
            node.scope += "."+node.parent.nodes[0].name
            #node.scope = "."+node.parent.nodes[0].name

          when SyntaxTree::CONSTS["CALL"]
            node.scope += "."+node.parent.parent.parent.name

          when SyntaxTree::CONSTS["LIST"]
            ## mootools Class
            #if node.parent.parent.nodes[0].name == "Class"
              #if node.parent.parent.parent.type == SyntaxTree::CONSTS["IDENTIFIER"]
                #node.scope += "."+node.parent.parent.parent.name
              #else
                #node.scope += "."+node.parent.parent.parent.nodes[0].name
              #end
            #end
            ## mootools Native
            #if node.parent.parent.nodes[0].name == "Native"
              #node.scope += "."+node.parent.parent.parent.name
            #end
            ## mootools $merge
            #if node.parent.parent.nodes[0].name == "$merge"
              #node.scope += "."+node.parent.parent.parent.name
            #end
            ## mootools implement
            #if node.parent.parent.nodes[0].nodes[1] && node.parent.parent.nodes[0].nodes[1].name == "implement"
              #node.scope += "."+node.parent.parent.nodes[0].nodes[0].name
            #end

          else # default case
            if node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"]
              node.scope += "."+node.parent.nodes[0].name
            else
              node.scope += "."+node.parent.name if node.parent.name != ""
            end
        end
      end
    end

    # scope
    if node.type == SyntaxTree::CONSTS["SCRIPT"] && node.parent.type == SyntaxTree::CONSTS["FUNCTION"]
      if node.parent.name != 'function'
        node.scope = node.parent.scope+"::"+node.parent.name
      else
        node.parent.name = tree.new_closure
        node.scope = node.scope+"::"+node.parent.name
        node.parent.kind = SyntaxTree::CTAGS_TYPES[SyntaxTree::TOKENS[SyntaxTree::CONSTS["FUNCTION"]]]
      end
    end

    # RETURN
    if node.parent.type == SyntaxTree::CONSTS["RETURN"]
      node.scope.sub!(/::([^:]+)$/, '.\1')
      # var A = (function(){ return { a: 1} })();
      if node.parent.parent && node.parent.parent.parent && node.parent.parent.parent.parent && node.parent.parent.parent.parent.parent && node.parent.parent.parent.parent.parent.type == SyntaxTree::CONSTS["CALL"]
        if [SyntaxTree::CONSTS["IDENTIFIER"], SyntaxTree::CONSTS["DOT"]].include?(node.parent.parent.parent.parent.parent.parent.type)
          node.scope = node.parent.parent.parent.parent.parent.parent.scope+"."+node.parent.parent.parent.parent.parent.parent.name
        end
        # A = (function(){ return { a: 1} })();
        if [SyntaxTree::CONSTS["IDENTIFIER"], SyntaxTree::CONSTS["DOT"]].include?(node.parent.parent.parent.parent.parent.parent.nodes[0].type)
          node.scope = node.parent.parent.parent.parent.parent.parent.nodes[0].scope+"."+node.parent.parent.parent.parent.parent.parent.nodes[0].name
        end
      end
    end
  end

  #
  # set node kind
  #
  def self.process_second(node, tree)
    # resolve DOT
    if node.type == SyntaxTree::CONSTS["DOT"]
      node.type = node.nodes[0].type
      node.nodes = []
    end

    # THIS
    if node.name =~ /(\.|^)this\./
      node.type = SyntaxTree::CONSTS["IDENTIFIER"]
    end
    if node.type == SyntaxTree::CONSTS["THIS"]
      node.kind = 'this' unless node.kind
    end

    # ASSIGN
    if node.type == SyntaxTree::CONSTS["ASSIGN"]
      if node.nodes[1].type == SyntaxTree::CONSTS["FUNCTION"]
        node.nodes[0].kind = (node.nodes[1].scope == "" ? "" : node.nodes[1].scope+"::")+node.nodes[1].name
      else
        if !node.nodes[0].kind
          begin
            node.nodes[0].kind = node.nodes[1].kind ? node.nodes[1].kind : (([SyntaxTree::CONSTS["IDENTIFIER"], SyntaxTree::CONSTS["DOT"]].include?(node.nodes[1].type)) ? node.nodes[1].name : SyntaxTree::CTAGS_TYPES[SyntaxTree::TOKENS[node.nodes[1].type]])
          rescue
            print "non-critical error in line "+node.lineno.to_s+" ... " if $debug
            node.nodes[0].kind = SyntaxTree::CTAGS_TYPES["RUNTIME"]
            #node.nodes[0].kind = node.nodes[0].scope = ""
            #node.nodes[0].skip = true
          end
        end
      end
      # function B { this.a = new String(); }
      if node.nodes.length == 2 && (node.nodes[1].type == SyntaxTree::CONSTS["NEW"] || node.nodes[1].type == SyntaxTree::CONSTS["NEW_WITH_ARGS"])
        if node.nodes[1].nodes[0].type == SyntaxTree::CONSTS["GROUP"]
          node.nodes[0].kind = node.nodes[1].nodes[0].nodes[0].name
        else
          node.nodes[0].kind = node.nodes[1].nodes[0].name
        end
      end
      if node.nodes.length == 2 && node.nodes[1].type == SyntaxTree::CONSTS["THIS"]
        node.nodes[0].kind = 'this'
      end
      # prepend scope to kind if we are inside scope
      if node.nodes[0].scope != '' && node.nodes[1].type != SyntaxTree::CONSTS["ASSIGN"] && node.nodes[1].type != SyntaxTree::CONSTS["FUNCTION"]
        begin
          node.nodes[0].kind = node.nodes[0].scope+'::'+node.nodes[0].kind
        rescue
          print "non-critical error in line "+node.lineno.to_s+" ... " if $debug
          node.nodes[0].kind = SyntaxTree::CTAGS_TYPES["RUNTIME"]
          #node.nodes[0].kind = node.nodes[0].scope = ""
          #node.nodes[0].skip = true
        end
      end
      if node.nodes[1].type == SyntaxTree::CONSTS["NEW_WITH_ARGS"]
        node.nodes[0].kind =  node.nodes[1].nodes[0].name
      end
      if node.nodes[1].type == SyntaxTree::CONSTS["CALL"] && node.nodes[1].nodes[0].type == SyntaxTree::CONSTS["FUNCTION"] && node.nodes[1].nodes[0].nodes[0] && node.nodes[1].nodes[0].nodes[0].type == SyntaxTree::CONSTS["SCRIPT"]
        node.nodes[0].kind = (node.nodes[1].nodes[0].scope == "" ? "" : node.nodes[1].nodes[0].scope+"::")+node.nodes[1].nodes[0].name
      end
      # set kind to RUNTIME if it is impossible to determine kind of a node
      # i.e. selector = selector || document;
      unless node.nodes[0].kind
        node.nodes[0].kind = SyntaxTree::CTAGS_TYPES["RUNTIME"]
      end
      node.kind = node.nodes[0].kind
    end

    # VAR
    if node.parent.type == SyntaxTree::CONSTS["VAR"] && node.type == SyntaxTree::CONSTS["IDENTIFIER"] && !node.kind
      if node.nodes.length == 1
        case node.nodes[0].type
          when SyntaxTree::CONSTS["IDENTIFIER"], SyntaxTree::CONSTS["ASSIGN"]
            node.kind = node.nodes[0].kind || node.nodes[0].name

          when SyntaxTree::CONSTS["NEW"], SyntaxTree::CONSTS["NEW_WITH_ARGS"]
            if node.nodes[0].nodes[0].type == SyntaxTree::CONSTS["GROUP"]
              node.kind = node.nodes[0].nodes[0].nodes[0].name
            else
              node.kind = node.nodes[0].nodes[0].name
            end

          when SyntaxTree::CONSTS["DOT"], SyntaxTree::CONSTS["THIS"]
            node.kind = node.nodes[0].name

          when SyntaxTree::CONSTS["FUNCTION"]
            node.kind = node.nodes[0].name

          when SyntaxTree::CONSTS["INDEX"] # var match = quickExpr.exec( selector );
            node.kind = SyntaxTree::CTAGS_TYPES["RUNTIME"]

          when SyntaxTree::CONSTS["CALL"] # var match = quickExpr.exec( selector );
            if node.nodes[0].type == SyntaxTree::CONSTS["CALL"] && node.nodes[0].nodes[0].type == SyntaxTree::CONSTS["FUNCTION"] && node.nodes[0].nodes[0].nodes[0] && node.nodes[0].nodes[0].nodes[0].type == SyntaxTree::CONSTS["SCRIPT"]
              node.kind = (node.nodes[0].nodes[0].scope == "" ? "" : node.nodes[0].nodes[0].scope+"::")+node.nodes[0].nodes[0].name
            else
              node.kind = SyntaxTree::CTAGS_TYPES["RUNTIME"]
            end

          when SyntaxTree::CONSTS["GROUP"] # function A(){ var a = (1) ? 2 : 2; }
            node.kind = SyntaxTree::CTAGS_TYPES["RUNTIME"]

          else
            node.kind = SyntaxTree::CTAGS_TYPES[SyntaxTree::TOKENS[node.nodes[0].type]]
        end
      else
        node.kind = SyntaxTree::CTAGS_TYPES["OBJECT"]
      end

      # prepend node.scope to node.kind if we are inside scope
      if ((node.nodes.length == 1 && node.nodes[0].type != SyntaxTree::CONSTS["ASSIGN"]) || node.nodes.length == 0) && node.scope != ''
        # node.kind can be nil
        begin
          node.kind = node.scope+'::'+node.kind
        rescue
          print "non-critical error in line "+node.lineno.to_s+" ... " if $debug
          node.kind = node.scope = ""
          node.skip = true
        end
      end
    end

    # PROPERTY_INIT
    if node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"] && node.index == 0
      if node.parent.nodes[1].kind
        node.kind = node.parent.nodes[1].kind
      else
        node.kind = SyntaxTree::CTAGS_TYPES[SyntaxTree::TOKENS[node.parent.nodes[1].type]] || SyntaxTree::CTAGS_TYPES["OBJECT"]
      end
    end
    if node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"] && node.index == 1 && node.type == SyntaxTree::CONSTS["IDENTIFIER"]
      node.kind = SyntaxTree::CTAGS_TYPES["OBJECT"]
    end

    # FUNCTION
    if node.type == SyntaxTree::CONSTS["FUNCTION"]
      case node.parent.type
        # rules for anonymous function
        when SyntaxTree::CONSTS["GROUP"]
          node.name = node.nodes[0].scope.sub(/^.*::([^.:]+)$/, '\1')
          node.kind = node.scope+"::"+SyntaxTree::CTAGS_TYPES["FUNCTION"]

        # rules for anonymous function
        when SyntaxTree::CONSTS["SCRIPT"]
          node.kind = SyntaxTree::CTAGS_TYPES["FUNCTION"]
          # prepend node.scope to node.kind if we are inside scope
          if node.parent.parent && node.parent.parent.type == SyntaxTree::CONSTS["FUNCTION"]
            node.kind = node.scope+'::'+node.kind
          end

        else
          node.kind = node.scope+'::'+node.kind if node.scope != "" && node.kind
          if node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"] && node.index == 1
            node.parent.nodes[0].kind = node.scope+'::'+node.name
          end
      end
    end
  end

  #
  # add node to @data hash
  #
  def self.process_third(node, tree)
    if node.type != SyntaxTree::CONSTS["ASSIGN"]
      node.kind = node.kind.sub(/^::|^\./, '')

      # resolve 'window' in node.name
      if node.name =~ /^window\./
        node.scope = ""
        node.name.sub!(/^window\./, '')
      end
      # reduce node.name if it contains .
      if node.name =~ /\./
        node.reduced_name = String.new(node.name)
        path = node.name.split(".")
        node.name = path.pop
        node.scope += "."+path.join(".")
      end
      # resolve 'this' in node.kind
      node.kind.sub!(/::this\.([^.:]+)$/, '.\1') if node.kind =~ /this\./
      node.kind.sub!(/::this$/, '') if node.kind =~ /::this$/
      # resolve 'this' in node.scope
      node.scope.sub!(/::([^.:]+)\.this/, '.\1') if node.scope =~ /::[^.:]+\.this/
      # resolve buildin type in node.kind
      node.kind.sub!(/.*::([^.:]+)$/, '\1') if SyntaxTree::BUILDIN_TYPES.include?(node.kind.sub(/.*::([^.:]+)$/, '\1'))

      hash = {:name     => node.name,
              :kind     => node.kind,
              :scope    => node.scope,
              :filename => $filename,
              :lineno   => node.lineno,
              :line     => $lines ? "/^"+$lines[node.lineno-1].sub(/(\r)?\n$/, "")+"$/;" : "",
            }

      hash_key = hash[:scope]+"|"+hash[:name]

      if tree.data.include?(hash_key) && !(SyntaxTree::BUILDIN_TYPES.include?(tree.data[hash_key][:kind]))
        node.name = hash[:name] = tree.data[hash_key][:kind]
        node.scope = hash[:scope] = ""
        hash_key = hash[:scope]+"|"+hash[:name]
      end
      tree.data[hash_key] = hash
    end
  end

  #
  # finalize @data hash
  #
  def self.process_fourth(node, tree)
    resolved_scope = []
    # replace functions names in node.scope
    if (
        ((node.type == SyntaxTree::CONSTS["IDENTIFIER"] || node.type == SyntaxTree::CONSTS["FUNCTION"]) && 
          (node.parent.type == SyntaxTree::CONSTS["ASSIGN"] || node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"])) ||
        (node.index == 0 && node.type == SyntaxTree::CONSTS["STRING"] && node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"])
        ) &&
        node.scope =~ /\./

      parent = node
      ext_skip = false
      while parent = parent.parent do
        if parent.nodes[0].name == 'Ext.extend' || parent.nodes[0].name == 'Ext.apply' || parent.nodes[0].name == 'Ext.applyIf'
          ext_skip = true
          break
        end
      end

      unless ext_skip
        old_scope = node.scope
        tmp = node.scope.split(".")

        tmp.each_index do |key|
          tmp_scope = key-1 >= 0 ? tmp[0..key-1].join('.') : ""
          if tree.data[node.scope+"|"+node.name] && tree.data[tmp_scope+"|"+tmp[key]] && !SyntaxTree::BUILDIN_TYPES.include?(tree.data[tmp_scope+"|"+tmp[key]][:kind].sub(/.*::/, ''))
            tmp[key] = tree.data[tmp_scope+"|"+tmp[key]][:kind].split('::')[-1]
          end
        end
        tmp = tmp.join('.')
        if tmp != node.scope
          node.scope = tmp
          tree.data[node.scope+"|"+node.name] = tree.data[old_scope+"|"+node.name]
          tree.data[node.scope+"|"+node.name][:scope] = node.scope
          tree.data.delete(old_scope+"|"+node.name)
        end
      end
    end
    # resolve node.scope
    if node.type == SyntaxTree::CONSTS["IDENTIFIER"] && node.parent.type == SyntaxTree::CONSTS["ASSIGN"] && node.index == 0 && node.scope =~ /::/
      # return if variable is already moved
      # i.e. (function(){ a = '1'; a = '2'; })()
      return node unless tree.data[node.scope+"|"+node.name]
      old_scope = node.scope

      unless node.scope =~ /\.[^\.]+$/ && tree.data[node.scope.sub(/\.([^.]+)$/, '|\1')]
        stack = node.scope.split("::")
        while popped = stack.pop do
          node.scope = ("::"+stack.join).sub(/^::$/, '')
          break if tree.data[node.scope+"|"+node.name]
        end
        tree.data[node.scope+"|"+node.name] = tree.data[old_scope+"|"+node.name]
        tree.data[node.scope+"|"+node.name][:scope] = node.scope
        tree.data.delete(old_scope+"|"+node.name)

        # save resolved scope
        resolved_scope = [old_scope+"."+node.name, node.scope+"."+node.name]
      end
    end
    # check current scope on saved resolved scopes
    if tree.resolved_scopes.include?(node.scope)
      old_scope = node.scope
      node.scope = tree.resolved_scopes[node.scope]
      tree.data[node.scope+"|"+node.name] = tree.data[old_scope+"|"+node.name]
      tree.data[node.scope+"|"+node.name][:scope] = node.scope
      tree.data.delete(old_scope+"|"+node.name)
    end
    # Object.extend
    if node.type == SyntaxTree::CONSTS["IDENTIFIER"] && node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"] && node.index == 0 && node.scope =~ /::/ &&
        ["Object.extend"].include?(node.parent.parent.parent.parent.nodes[0].name)
      node.scope.sub!(/.*::[^.]+/, '')
    end

    # resolve node.kind
    if node.type == SyntaxTree::CONSTS["IDENTIFIER"] &&
        ((node.parent.type == SyntaxTree::CONSTS["VAR"] && node.nodes.length == 1) || (node.parent.type == SyntaxTree::CONSTS["ASSIGN"] && node.index == 0)) &&
        node.kind =~ /::/ && !SyntaxTree::BUILDIN_TYPES.include?(node.kind.match(/[^:]+$/)[0]) &&
        tree.data[node.scope+"|"+node.name]

      unless tree.data["::"+node.kind.sub(/::([^:.]+)$/, '|\1')]
        stack = node.kind.split("::")
        kind = stack.pop
        while stack.pop do
          new_scope = stack.join
          new_key = "::"+new_scope+"|"+kind
          if tree.data[new_key]
            node.kind = new_scope+"::"+kind
            break
          end
        end
        # set node.kind to global if its upper definition doesn't exist
        if stack.length == 0
          node.kind = kind
        end
        tree.data[node.scope+"|"+node.name][:kind] = node.kind
      end
    end
    # resolve 'window' in node.kind
    if node.kind =~ /^window\./ && tree.data[node.scope+"|"+node.name]
      node.kind.sub!(/^window./, '')
      tree.data[node.scope+"|"+node.name][:kind] = node.kind
    end
    # check if scope contains reduced name
    if node.reduced_name && !node.reduced_name.index("this") && node.scope == "" && node.name !~ /CLOSURE_\d+/
      path = node.reduced_name.split(".")
      path.pop
      path = "."+path.join(".")
      if !node.scope.match(Regexp.new("(::|.|^)"+path+"(::|.|$)"))
        item = tree.data[node.scope+"|"+node.name]
        tree.data.delete(node.scope+"|"+node.name)
        node.scope = item[:scope] = path
        tree.data[node.scope+"|"+node.name] = item
        resolved_scope[1] = node.scope+"."+node.name
      end
    end

    if resolved_scope[0] != ""
      tree.resolved_scopes[resolved_scope[0]] = resolved_scope[1]
    end
  end
end
