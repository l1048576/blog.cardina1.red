module Larry
  module Archive
    include Nanoc::Helpers::HTMLEscape
    ARCHIVE_LIST_CAPACITY = 15

    def articles_by_year_month
      blk = -> {
        result = {}
        current_year = nil
        current_month = nil
        current_year_items = nil
        current_month_items = nil

        sorted_articles.each do |article|
          created_at = article[:created_at]
          if current_year != created_at.year
            current_year = created_at.year
            current_year_items = result[current_year] = {}
            current_month = created_at.month
            current_month_items = current_year_items[current_month] = []
          elsif current_month != created_at.month
            current_month = created_at.month
            current_month_items = current_year_items[current_month] = []
          end
          current_month_items << article
        end
        result
      }

      if @items.frozen?
        @article_items_by_year_month ||= blk.call
      else
        blk.call
      end
    end

    def create_archive_pages
      archives_root = '/archives'
      articles_by_year_month.each do |year, year_items|
        year4 = sprintf('%04d', year)
        page_path = archives_root + "/#{year4}/index.html"
        @items.create(
          # content
          '',
          # attributes
          {
            :title => "Archive: #{year4}",
            :year => year,
          },
          # path
          page_path)
        year_items.each do |month, month_items|
          month2 = sprintf('%02d', month)
          page_path = archives_root + "/#{year4}/#{month2}/index.html"
          @items.create(
            # content
            '',
            # attributes
            {
              :title => "Archive: #{year4}/#{month2}",
              :year => year,
              :month => month,
            },
            # path
            page_path)
        end
      end
    end

    def create_article_list_pages
      num_pages = (sorted_articles.size + ARCHIVE_LIST_CAPACITY - 1) / ARCHIVE_LIST_CAPACITY
      (0...num_pages).each do |page_index|
        num_articles = if page_index == num_pages - 1
          sorted_articles.size % ARCHIVE_LIST_CAPACITY
        else
          ARCHIVE_LIST_CAPACITY
        end
        index_first = page_index * ARCHIVE_LIST_CAPACITY
        index_last = index_first + num_articles - 1
        @items.create(
          # content
          '',
          # attributes
          {
            title: "Archive[#{page_index}]",
            index_first: index_first,
            index_last: index_last,
            num_articles: num_articles,
            page_index: page_index,
            num_pages: num_pages,
          },
          # path
          "/list/#{page_index}.html")
      end

      periods = sorted_articles.reverse.each_slice(ARCHIVE_LIST_CAPACITY).map {|articles| [articles[0][:created_at], articles[-1][:created_at]]}
      @items.create(
        # content
        '',
        # attributes
        {
          title: 'Archive (list)',
          periods: periods
        },
        # path
        "/list/index.html")
    end
  end
end

include Larry::Archive
