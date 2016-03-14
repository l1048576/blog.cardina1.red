module Larry
  module HierarchicalTagPages
    include Larry::HierarchicalTag

    def create_htag_pages(htag_base_dir, items: @items)
      # htags_base_dir should have trailing slash.
      htag_base_dir += '/' unless htag_base_dir.end_with?('/')
      def create_sub_tag_pages(current_tag, children, htag_base_dir)
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
        children.each do |child_frag, children|
          create_sub_tag_pages(current_tag + '/' + child_frag, children, htag_base_dir)
        end
      end
      tag_tree = all_htag_tree(items)
      tag_tree.each do |frag, children|
        create_sub_tag_pages(frag, children, htag_base_dir)
      end
    end

  end
end

include Larry::HierarchicalTagPages
