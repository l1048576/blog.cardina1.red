module Larry
  module Archive
    include Nanoc::Helpers::HTMLEscape
    ARCHIVE_LIST_CAPACITY = 15

    # Descending order of year.
    # [(year, (article_first_index, article_last_index)]
    # (currently unused.)
    def article_years_indices
      blk = -> {
        sorted_articles.map.with_index {|item, i| [item, i]} # [(item, index)]
        group_by {|it_i| it_i[0][:created_at].year}.to_a.sort.reverse. # [(year, [(item, index)])]
          map {|y_its_is|
            minmax = y_its_is[1].map {|it_i| it_i[1]}.minmax
            [y_its_is[0], minmax]
          } # [(year, (first_index, last_index))]
      }
      if @items.frozen?
        @article_years_indices ||= blk.call
      else
        blk.call
      end
    end

    # Descending order.
    # [year]
    def article_years
      blk = -> {
        articles.map {|item| item[:created_at].year}.uniq.sort.reverse
      }
      if @items.frozen?
        @article_years ||= blk.call
      else
        blk.call
      end
    end

    # Descending order of year & month.
    # [(year, month), (first_index, last_index))]
    def article_years_and_months_indices
      blk = -> {
        sorted_articles.map.with_index {|item, i| [item, i]}. # [(item, index)]
          group_by {|it_i|
            created_at = it_i[0][:created_at]
            [created_at.year, created_at.month]
          }. # [((year, month), [(item, index)])]
          map {|ym_its_is|
            minmax = ym_its_is[1].map {|it_i| it_i[1]}.minmax
            [ym_its_is[0], minmax]
          }. # [((year, month), (first_index, last_index))]
          sort_by {|ym_fl| ym_fl[0]}.reverse # Descending order of year & month.
      }
      if @items.frozen?
        @article_years_and_months_indices ||= blk.call
      else
        blk.call
      end
    end

    # Descending order of year & month.
    # [(year, month)]
    def article_years_and_months
      blk = -> {
        articles.map {|item| [item[:created_at].year, item[:created_at].month]}.uniq.sort.reverse
      }
      if @items.frozen?
        @article_years_and_months ||= blk.call
      else
        blk.call
      end
    end

    def create_archive_pages
      # years: [year]
      years = article_years
      years_months = article_years_and_months
      # ym_fl_arr: [((year, month), (first_i, last_i))]
      ym_fl_arr = article_years_and_months_indices
      # y_mifls_arr: [(year, [month, ym_index, (first_i, last_i)])]
      y_mifls_arr = ym_fl_arr.
        map.with_index {|ym_fl, i| [ym_fl[0], i, ym_fl[1]]}. # [((year, month), ym_index, (first_i, last_i))]
        group_by {|ym_i_fl| ym_i_fl[0][0]}.to_a.sort.reverse. # [(year, [((year, month), ym_index, (first_i, last_i))])]
        map {|y_ymifls| [y_ymifls[0], y_ymifls[1].map {|ym_i_fl|
          [ym_i_fl[0][1], ym_i_fl[1], ym_i_fl[2]]
        }]} # [(year, [(month, ym_index, (first_i, last_i))])]
      y_mifls_arr.each_with_index do |y_mifls, year_index|
        year = y_mifls[0]
        # m_i_fl_arr: [(month, ym_index, (first_i, last_i))]
        m_i_fl_arr = y_mifls[1]
        next_year = years[year_index - 1] if year_index > 0
        prev_year = years[year_index + 1] if year_index < years.size - 1
        year4 = sprintf('%04d', year)
        next_year4 = sprintf('%04d', next_year) if next_year
        prev_year4 = sprintf('%04d', prev_year) if prev_year
        # months: [(month, month2, (first_i, last_i))]
        months = m_i_fl_arr.map {|m_i_fl|
          [m_i_fl[0], sprintf('%02d', m_i_fl[0]), m_i_fl[2]]
        }

        # Create an yearly archive.
        @items.create(
          # content
          '',
          # attributes
          {
            title: "Archive: #{year4}",
            year4: year4,
            next_year4: next_year4,
            prev_year4: prev_year4,
            months: months,
          },
          # path
          "/#{year4}/index.html")

        # Create monthly archives.
        m_i_fl_arr.each do |m_i_fl|
          month = m_i_fl[0]
          ym_index = m_i_fl[1]
          first_index = m_i_fl[2][0]
          last_index = m_i_fl[2][1]
          next_ym = years_months[ym_index - 1] if ym_index > 0
          prev_ym = years_months[ym_index + 1] if ym_index < years_months.size - 1
          month2 = sprintf('%02d', month)
          next_ym_year4 = sprintf('%04d', next_ym[0]) if next_ym
          next_ym_month2 = sprintf('%02d', next_ym[1]) if next_ym
          prev_ym_year4 = sprintf('%04d', prev_ym[0]) if prev_ym
          prev_ym_month2 = sprintf('%02d', prev_ym[1]) if prev_ym
          @items.create(
            # content
            '',
            # attributes
            {
              title: "Archive: #{year4}",
              year4: year4,
              month: month,
              month2: month2,
              next_ym_year4: next_ym_year4,
              next_ym_month2: next_ym_month2,
              prev_ym_year4: prev_ym_year4,
              prev_ym_month2: prev_ym_month2,
              first_index: first_index,
              last_index: last_index,
            },
            # path
            "/#{year4}/#{month2}/index.html")
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
