module Larry
  # See https://github.com/nanoc/nanoc/blob/master/lib/nanoc/filters/xsl.rb
  class XSL < Nanoc::Filter
    identifier :larry_xsl
    requires 'nokogiri'

    def run(_content, params = {})
      Nanoc::Extra::JRubyNokogiriWarner.check_and_warn

      xsl_path = params[:xsl]
      if xsl_path.nil?
        raise 'XSL path is not specified'
      end

      parse_opts = ::Nokogiri::XML::ParseOptions::new.strict.norecover.nonoent
      xml = ::Nokogiri::XML(assigns[:content], nil, nil, parse_opts)
      xsl = ::Nokogiri::XSLT(File.open(xsl_path))

      xsl.apply_to(xml, ::Nokogiri::XSLT.quote_params(params[:params] || {}))
    end
  end
end
