module Larry
  module Archive
    include Nanoc::Helpers::HTMLEscape
    ARCHIVE_LIST_CAPACITY = 15

    # Descending order of year.
    # [(year, (article_first_index, article_last_index)]
    # (currently unused.)
    def article_years_indices
      blk = -> {
        sorted_articles.map.with_index. # [(item, index)]
        group_by {|item, _i| item[:created_at].year}.to_a.sort.reverse. # [(year, [(item, index)])]
          map {|year, it_i_arr|
            [year, it_i_arr.map {|_item, i| i}.minmax]
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
        sorted_articles.map.with_index. # [(item, index)]
          group_by {|item, _i|
            created_at = item[:created_at]
            [created_at.year, created_at.month]
          }. # [((year, month), [(item, index)])]
          map {|ym, it_i_arr|
            [ym, it_i_arr.map {|_item, i| i}.minmax]
          }. # [((year, month), (first_index, last_index))]
          sort_by {|ym, _fl| ym}.reverse # Descending order of year & month.
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
      # years_months: [(year, month)]
      years_months = article_years_and_months
      # ym_fl_arr: [((year, month), (first_i, last_i))]
      ym_fl_arr = article_years_and_months_indices
      # y_mifls_arr: [(year, [month, ym_index, (first_i, last_i)])]
      y_mifls_arr = ym_fl_arr.
        map.with_index {|(ym, fl), i| [ym, i, fl]}. # [((year, month), ym_index, (first_i, last_i))]
        group_by {|(year, _m), _i, _fl| year}.to_a.sort.reverse. # [(year, [((year, month), ym_index, (first_i, last_i))])]
        map {|year, ym_i_fl_arr|
          [year, ym_i_fl_arr.map {|(_y, month), i, fl| [month, i, fl]}]
        } # [(year, [(month, ym_index, (first_i, last_i))])]
      y_mifls_arr.each_with_index do |(year, m_i_fl_arr), year_index|
        # m_i_fl_arr: [(month, ym_index, (first_i, last_i))]
        next_year = years[year_index - 1] if year_index > 0
        prev_year = years[year_index + 1] if year_index < years.size - 1
        year4 = sprintf('%04d', year)
        next_year4 = sprintf('%04d', next_year) if next_year
        prev_year4 = sprintf('%04d', prev_year) if prev_year
        # months: [(month, month2, (first_i, last_i))]
        months = m_i_fl_arr.map {|month, _i, fl|
          [month, sprintf('%02d', month), fl]
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
          source_path_for_archive(year4))

        # Create monthly archives.
        m_i_fl_arr.each do |month, ym_index, (first_index, last_index)|
          next_year_month = years_months[ym_index - 1] if ym_index > 0
          prev_year_month = years_months[ym_index + 1] if ym_index < years_months.size - 1
          month2 = sprintf('%02d', month)
          next_year4_month2 = if ((y, m) = next_year_month)
                                [sprintf('%04d', y), sprintf('%02d', m)]
                              end
          prev_year4_month2 = if ((y, m) = prev_year_month)
                                [sprintf('%04d', y), sprintf('%02d', m)]
                              end
          @items.create(
            # content
            '',
            # attributes
            {
              title: "Archive: #{year4}",
              year4: year4,
              month: month,
              month2: month2,
              next_year4_month2: next_year4_month2,
              prev_year4_month2: prev_year4_month2,
              first_index: first_index,
              last_index: last_index,
            },
            # path
            source_path_for_archive(year4, month2))
        end
      end
      # y_ms: [(year, [month])]
      y_ms = y_mifls_arr.map {|year, m_i_fl_arr|
        [year, m_i_fl_arr.map {|month, _i, _fl| month}]
      }
      @items.create(
        # content
        '',
        # attributes
        {
          title: "Archive",
          year_months: y_ms,
        },
        # path
        source_path_for_archive)
    end

    def article_list_num_pages
      (articles.size + ARCHIVE_LIST_CAPACITY - 1) / ARCHIVE_LIST_CAPACITY
    end

    def create_article_list_pages
      num_pages = article_list_num_pages
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
          source_path_for_article_list(page_index))
      end

      periods = sorted_articles.reverse.each_slice(ARCHIVE_LIST_CAPACITY).map {|articles| [articles.first[:created_at], articles.last[:created_at]]}
      @items.create(
        # content
        '',
        # attributes
        {
          title: 'Archive (list)',
          periods: periods
        },
        # path
        source_path_for_article_list)
    end

    def source_path_for_archive(year=nil, month=nil)
      if year.nil?
        '/archive.html'
      else
        year = sprintf('%04d', year) if year.is_a?(Integer)
        if month.nil?
          "/#{year}/index.html"
        else
          month = sprintf('%04d', month) if month.is_a?(Integer)
          "/#{year}/#{month}/index.html"
        end
      end
    end

    # page: Integer
    def source_path_for_article_list(page=nil)
      if page.nil?
        '/list/index.html'
      elsif page >= 0 && page < article_list_num_pages
        "/list/#{page}.html"
      end
    end
  end
end

include Larry::Archive
