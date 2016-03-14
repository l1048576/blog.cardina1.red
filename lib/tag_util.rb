module Larry
  module TagUtil
    include Nanoc::Helpers::HTMLEscape

    # see http://blog.designrecipe.jp/2010/07/25/nanoc-customize-tag/ .
    def count_by_tag(items = nil)
      items ||= @items

      count_by_tag = Hash.new(0)
      items.each do |item|
        if itemtags = item[:tags]
          itemtags.each do |tag|
            count_by_tag[tag] += 1
          end
        end
      end
      count_by_tag
    end

    def tag_set(items = nil)
      require 'set'

      items ||= @items
      tags = Set.new
      items.each do |item|
        if item_tags = item[:tags]
          item_tags.each { |tag| tags << tag }
        end
      end
      tags.to_a
    end

    def create_tag_pages
      tag_set(articles).each do |tag|
        page_path = "/tags/#{h tag}/index.html"
        content = ''
        @items.create(
          # content
          content,
          # attributes
          {
            :title => "Tag #{tag}",
            :target_tag => "#{tag}",
          },
          # path
          page_path)
      end
    end
  end
end

include Larry::TagUtil
