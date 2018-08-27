module Larry
  # See <https://github.com/nanoc/nanoc/blob/4.9.4/nanoc/lib/nanoc/filters/xsl.rb>
  class XSL < Nanoc::Filter
    identifier :larry_xsl

    requires 'nokogiri'

    always_outdated

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

      parse_opts = ::Nokogiri::XML::ParseOptions::new.strict.norecover.nonoent
      xml = ::Nokogiri::XML(assigns[:content], nil, nil, parse_opts)
      xsl = ::Nokogiri::XSLT(@layouts[xsl_path].raw_content)

      xsl.apply_to(xml, ::Nokogiri::XSLT.quote_params(params))
    end
  end
end
