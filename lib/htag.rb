module Larry
  module HierarchicalTag
    # HTMLEscape: `h()`
    include Nanoc::Helpers::HTMLEscape
    # erb: `u()`
    require 'erb'
    include ERB::Util
    # json: `JSON`
    require 'json'

    # tag_path (String, unescaped) -> tag_path_array([String], unescaped)
    def decompose_htagpath(path)
      path.split('/').take_while{|frag|
        # 潜在的な危険性のある文字列を発見したら、そのパスについては
        # 危険な文字列以降を捨てる。
        # (たとえば'a/b/../c'であれば'a/b'までが使われる)。
        # 空文字列でない
        !frag.empty? &&
        # "index.html" でない(タグページに使うため、この名前のディレクトリができては困る)
        (frag != 'index.html') &&
        # '..'でない
        (frag != '..') &&
        # backslash ('\\')を含まない
        !frag.include?('\\') &&
        # asterisk ('*')を含まない
        !frag.include?('*') &&
        # tilde ('~')を含まない
        !frag.include?('~')
      }
    end

    # htag :: String(unescaped)
    # return :: String(html)
    # "a/b/c" ->
    #   "<li><a href="#{tags_root}#{h u(a)}/index.html">#{h a}</a></li>
    #    <li><a href="#{tags_root}#{h u(a)}/#{h u(b)}/index.html">#{h b}</a></li>
    #    <li><a href="#{tags_root}#{h u(a)}/#{h u(b)}/#{h u(c)}/index.html">#{h c}</a></li>"
    def htag_breadcrumb_li(htag, tags_base_dir, attributes={})
      buffer = ''.dup
      decompose_htagpath(htag).each_with_object(tags_base_dir.dup){|tag, current_path|
        current_path << u(tag) + '/'
        buffer << "<li>#{link_to_unless_current h(tag), current_path+'index.html', attributes}</li>"
      }
      buffer
    end

    # Node: Map<String, Node>
    def all_htag_tree(items=@items)
      root = {}
      items.collect{|item| item[:htags]}.select{|htags|
        !htags.nil? && !htags.empty?
      }.each do |htags|
        htags.each do |htag|
          current = root
          decompose_htagpath(htag).each do |frag|
            current[frag] ||= {}
            current = current[frag]
          end
        end
      end
      root
    end

    def articles_htag_tree
      blk = -> {
        all_htag_tree(articles)
      }
      if @items.frozen?
        @articles_htag_tree ||= blk.call
      else
        blk.call
      end
    end

    class TagNode
      attr_accessor :name, :path, :children, :item_exact, :item_descendant, :rel_uri

      # For the root node, name='' and parent=nil.
      def is_root
        @name.empty? && @parent.nil?
      end

      def initialize(name, parent=nil)
        @name = name
        if parent.nil?
          @path = ''
          @rel_uri = ''
        elsif parent.is_root
          @path = name
          @rel_uri = u(name)
        else
          @path = parent.path + '/' + name
          @rel_uri = parent.rel_uri + '/' + u(name)
        end
        @children = []
        @item_exact = []
        @item_descendant = []
      end

      def child(name, create=false)
        c = @children.find{|child| child.name == name}
        if create && c.nil?
          c = TagNode.new(name, self)
          @children << c
        end
        c
      end

      def get_node(htag, create=false)
        if slash_index = htag.index('/')
          child_frag = htag.slice(0...slash_index)
          c = child(child_frag, create)
          c.get_node(htag.slice(slash_index+1..-1), create) unless c.nil?
        else
          child(htag, create)
        end
      end

      def add_item(htag, item)
        frags = decompose_htagpath(htag)
        current = self
        frags.each do |frag|
          current.item_descendant << item
          current = current.child(frag, true)
        end
        current.item_exact << item
      end

      def each(&block)
        yield self
        @children.each do |child|
          child.each(&block)
        end
        self
      end

      def items_uniq!
        @item_exact.uniq!
        @item_descendant.uniq!
        @children.each do |child|
          child.items_uniq!
        end
      end
    end

    def htag_items_tree(items=@items)
      root_node = TagNode.new('', nil)
      items.each do |item|
        (item[:htags] || []).map{|htag|
          decompose_htagpath(htag).join('/')
        }.each do |htag|
          root_node.add_item(htag, item)
        end
      end
      root_node.items_uniq!
      root_node
    end

    def articles_htag_items_tree
      blk = -> {
        htag_items_tree(articles)
      }
      if @items.frozen?
        @articles_htag_items_tree_cache ||= blk.call
      else
        blk.call
      end
    end

    def link_to_htag(tag_node, tagpage_base_dir, text=nil, options: {})
      text ||= h(tag_node.name)
      tagpage_base_dir += '/' unless tagpage_base_dir.end_with?('/')
      link_to text, tagpage_base_dir + tag_node.rel_uri + '/index.html', options
    end

    def print_tagtree(tag_node, tagpage_base_dir, node_text=nil, buffer: nil, options: {})
      buffer ||= ''.dup
      node_text ||= link_to_htag(tag_node, tagpage_base_dir, options)
      if (tag_node.children.count == 1) && tag_node.item_exact.empty?
        # Use concatenated `current/child` style.
        child = tag_node.children[0]
        print_tagtree(child, tagpage_base_dir, "#{node_text}/#{link_to_htag child, tagpage_base_dir}", buffer: buffer, options: options)
      else
        buffer << "<li>#{node_text}"
        buffer << " [#{tag_node.item_exact.count}/#{tag_node.item_descendant.count}]"
        children = tag_node.children
        unless children.empty?
          buffer << '<ul>'
          children.each do |child|
            print_tagtree(child, tagpage_base_dir, buffer: buffer)
          end
          buffer << '</ul>'
        end
        buffer << "</li>\n"
      end
      buffer
    end

  end
end

include Larry::HierarchicalTag
