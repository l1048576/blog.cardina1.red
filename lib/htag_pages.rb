module Larry
  module HierarchicalTagPages
    include Larry::HierarchicalTag

    # Creates tag page (html) and db (json).
    def create_htag_pages(htag_base_dir, items: @items)
      # htags_base_dir should have trailing slash.
      htag_base_dir += '/' unless htag_base_dir.end_with?('/')
      items_tree = articles_htag_items_tree
      def create_sub_tag_pages(current_tag, children, htag_base_dir, tag_node)
        @items.create(
          # content
          '',
          # attributes
          {
            :title => "Tag: #{current_tag}",
            :target => current_tag,
          },
          # path
          htag_base_dir + current_tag + '/index.html')
        @items.create(
          # content
          '',
          # attributes
          {
            :tag_node => tag_node,
          },
          # path
          htag_base_dir + current_tag + '/index.json')
        children.each do |child_frag, children|
          create_sub_tag_pages(current_tag + '/' + child_frag, children, htag_base_dir, tag_node.child(child_frag))
        end
      end
      tag_tree = all_htag_tree(items)
      tag_tree.each do |frag, children|
        create_sub_tag_pages(frag, children, htag_base_dir, items_tree.child(frag))
      end
    end

  end
end

include Larry::HierarchicalTagPages
