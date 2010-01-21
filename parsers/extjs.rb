class ExtJSParser

  #
  # set node scope
  #
  def self.process_first(node, tree)
    # scope
    if node.type == SyntaxTree::CONSTS["OBJECT_INIT"]
      if node.parent.type == SyntaxTree::CONSTS["LIST"]
        extJS_done = false
        # extend
        if node.parent.parent.nodes[0].nodes[1] && 
            (node.parent.parent.nodes[0].nodes[1].name == "extend" || ((node.parent.parent.nodes[0].nodes[1].name == "apply" || node.parent.parent.nodes[0].nodes[1].name == "applyIf") && node.parent.nodes[0].name == 'new')) &&
            node.parent.parent.nodes[0].nodes[0].name == "Ext"
          if node.parent.nodes[0].name == 'new'
            node.parent.nodes[0].name = node.parent.nodes[0].nodes[0].name
            node.parent.nodes[0].nodes[0].skip = true
          end
          if node.parent.nodes.length == 3
            node.scope += "."+node.parent.nodes[0].name
            node.parent.nodes[0].kind = node.parent.nodes[1].name
          end
          if node.parent.parent.parent.type == SyntaxTree::CONSTS["ASSIGN"]
            node.scope += "."+node.parent.parent.parent.nodes[0].name
            node.parent.parent.parent.nodes[0].kind = node.parent.nodes[0].name
          end
          if node.parent.parent.parent.parent.type == SyntaxTree::CONSTS["VAR"]
            node.scope += "."+node.parent.parent.parent.name
            node.parent.parent.parent.kind = node.parent.nodes[0].name
          end
          extJS_done = true
        end
        # apply
        if node.parent.parent.nodes[0].nodes[1] && (node.parent.parent.nodes[0].nodes[1].name == "apply" || node.parent.parent.nodes[0].nodes[1].name == "applyIf") &&
            node.parent.parent.nodes[0].nodes[0].name == "Ext" &&
            !extJS_done
          node.scope += "."+node.parent.nodes[0].name
          if node.parent.parent.parent.type == SyntaxTree::CONSTS["ASSIGN"]
            node.parent.parent.parent.nodes[0].kind = node.parent.nodes[0].name
          end
          if node.parent.parent.parent.parent.type == SyntaxTree::CONSTS["VAR"]
            node.parent.parent.parent.kind = node.parent.nodes[0].name
          end
        end
      end
    end

    # scope
    if node.type == SyntaxTree::CONSTS["IDENTIFIER"]
      if node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"]
        if node.parent.parent.parent.type == SyntaxTree::CONSTS["LIST"]
          # .addMethods
          if node.parent.parent.parent && node.parent.parent.parent.parent && node.parent.parent.parent.parent.nodes[0].name =~ /\.addMethods$/
            node.scope = '.'+node.parent.parent.parent.parent.nodes[0].name.sub(/\.addMethods$/, '')
          end
        end
      end
    end


    # scope
    if node.type == SyntaxTree::CONSTS["SCRIPT"] && node.parent.type == SyntaxTree::CONSTS["FUNCTION"]
      # Ext.A.addMethods({ a : function(){ } });
      #if node.parent.parent && node.parent.parent.parent && node.parent.parent.parent.parent && node.parent.parent.parent.parent.parent &&
         #node.parent.parent.parent.parent.parent.nodes[0].name =~ /\.addMethods$/
        #node.scope = node.parent.parent.parent.parent.parent.scope+"::"+node.parent.parent.parent.parent.parent.nodes[0].name.sub(/\.addMethods$/, '')
        #node.parent.scope = node.parent.parent.scope
        #node.parent.kind = nil
      #end
      #if node.parent.parent && node.parent.parent.nodes[0].name =~ /\.addMethods$/
        #node.scope = node.parent.parent.parent.parent.parent.name.sub(/\.addMethods$/, '')
      #end

      # Ext.apply(A, function(){ return {a:1} }());
      if node.parent.parent && node.parent.parent.parent && node.parent.parent.parent.parent && node.nodes[-1] &&
          node.nodes[-1].type == SyntaxTree::CONSTS["RETURN"] && node.nodes[-1].nodes[0].type == SyntaxTree::CONSTS["OBJECT_INIT"] &&
          node.parent.parent.type == SyntaxTree::CONSTS["CALL"] &&
          (node.parent.parent.parent.parent.nodes[0].name == "Ext.applyIf" || node.parent.parent.parent.parent.nodes[0].name == "Ext.apply" || node.parent.parent.parent.parent.nodes[0].name == "Ext.call")
        node.scope = node.parent.parent.scope+"::"+node.parent.parent.parent.nodes[0].name
        node.parent.scope = node.parent.parent.scope
        node.parent.kind = nil
      end
    end
  end

  #
  # set node kind
  #
  def self.process_second(node, tree)
  end

  #
  # add node to @data hash
  #
  def self.process_third(node, tree)
  end

  #
  # finalize @data hash
  #
  def self.process_fourth(node, tree)
    # ExtJS apply,extend
    if node.type == SyntaxTree::CONSTS["IDENTIFIER"] && node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"] && node.index == 0 && node.scope =~ /::/ &&
        ["Ext.extend", "Ext.apply", "Ext.applyIf"].include?(node.parent.parent.parent.parent.nodes[0].name)
      node.scope.sub!(/.*::[^.]+/, '')
    end
  end

end
