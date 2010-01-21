class PrototypeParser

  #
  # set node scope
  #
  def self.process_first(node, tree)
    # scope
    if node.type == SyntaxTree::CONSTS["OBJECT_INIT"]
      if node.parent.type == SyntaxTree::CONSTS["LIST"]
        # extend
        if node.parent.parent.nodes[0].nodes[1] && node.parent.parent.nodes[0].nodes[1].name == "extend" && node.parent.parent.nodes[0].nodes[0].name == "Object"
          if node.object_id == node.parent.nodes[0].object_id
            node.scope += "."+node.parent.parent.nodes[0].nodes[0].name
          else
            node.scope += "."+node.parent.nodes[0].name
          end
        end
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
    # Prototype extend
    if node.type == SyntaxTree::CONSTS["IDENTIFIER"] && node.parent.type == SyntaxTree::CONSTS["PROPERTY_INIT"] && node.index == 0 && node.scope =~ /::/ &&
        ["Object.extend"].include?(node.parent.parent.parent.parent.nodes[0].name)
      node.scope.sub!(/.*::[^.]+/, '')
    end
  end

end
