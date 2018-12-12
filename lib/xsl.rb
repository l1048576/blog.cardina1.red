module Larry
  XSLT_NAMESPACE = "http://www.w3.org/1999/XSL/Transform"
  XSLT_DEP_ATTRS = "(/xsl:stylesheet/xsl:import | /xsl:stylesheet/xsl:include)/@href"

  class XslImporter
    attr_reader :filter

    def initialize(filter)
      @filter = filter
    end

    def get_direct_deps(layouts, layout_dir, identifier)
      full_path = Pathname.new("#{layout_dir}#{layouts[identifier].identifier}")
      dirname = full_path.dirname
      content = layouts[identifier].raw_content
      xml = ::Nokogiri::XML(content)
      # TODO: Deal with `@base` attr.
      hrefs = xml.xpath(XSLT_DEP_ATTRS, 'xsl': XSLT_NAMESPACE)
      hrefs.map do |attr|
        href = attr.content
        abs_path = (dirname + href).cleanpath
        abs_path.relative_path_from(layout_dir)
      end
    end

    def get_all_deps(layouts, layout_dir, identifier)
      unchecked_deps = get_direct_deps(layouts, layout_dir, identifier)
      checked_deps = []
      loop do
        checking = unchecked_deps.pop
        break unless checking
        checking = "/#{checking}"

        direct_deps = get_direct_deps(layouts, layout_dir, checking)
        direct_deps.each do |direct|
          next if checked_deps.include?(direct) || unchecked_deps.include?(direct)
          unchecked_deps << direct
        end
        checked_deps << checking
      end
      checked_deps
    end
  end

  # See <https://github.com/nanoc/nanoc/blob/4.9.4/nanoc/lib/nanoc/filters/xsl.rb>
  class XSL < Nanoc::Filter
    identifier :larry_xsl

    requires 'nokogiri'

    # Runs the item content through an [XSLT](http://www.w3.org/TR/xslt)
    # stylesheet using  [Nokogiri](http://nokogiri.org/).
    #
    # @param [String] _content Ignored. As the filter can be run only as a
    #   layout, the value of the `:content` parameter passed to the class at
    #   initialization is used as the content to transform.
    #
    # @param [Hash] params The parameters that will be stored in corresponding
    #   `xsl:param` elements.
    #
    # @return [String] The transformed content
    def run(_content, params = {})
      Nanoc::Extra::JRubyNokogiriWarner.check_and_warn

      xsl_path = params[:xsl]
      if xsl_path.nil?
        raise 'XSL path is not specified'
      end

      current_dir = Pathname.pwd
      layout_dir = current_dir + 'layouts'
      xsl_dir = Pathname.new("#{layout_dir}#{@layouts[xsl_path].identifier.to_s}").dirname

      importer = XslImporter.new(self)
      deps = importer.get_all_deps(@layouts, layout_dir, xsl_path)
      deps.each do |dep|
        # TODO: I don't know what parameters to be passed to `bounce`.
        @layouts[xsl_path]._context.dependency_tracker.bounce(@layouts[dep]._unwrap)
      end

      xsl_xml = ::Nokogiri::XML(@layouts[xsl_path].raw_content)
      # TODO: Deal with `@base` attr.
      xsl_xml.xpath(XSLT_DEP_ATTRS, 'xsl': XSLT_NAMESPACE).each do |href|
        href.content = (xsl_dir + href).relative_path_from(current_dir).to_s
      end
      # TODO: Cache this `xsl` or `xsl_xml`.
      xsl = ::Nokogiri::XSLT::Stylesheet.parse_stylesheet_doc(xsl_xml)

      parse_opts = ::Nokogiri::XML::ParseOptions::new.strict.norecover.nonoent
      xml = ::Nokogiri::XML(assigns[:content], nil, nil, parse_opts)

      xsl.apply_to(xml, ::Nokogiri::XSLT.quote_params(params))
    end
  end
end
