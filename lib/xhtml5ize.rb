require 'nokogiri'
module Larry
  class Xhtml5Doc < ::Nokogiri::XML::SAX::Document
    attr_reader :content

    HTML_NS = 'http://www.w3.org/1999/xhtml'

    def initialize(html_mode=false)
      @content = "<!DOCTYPE html>\n".dup
      @is_prev_tag_omissible = false
      @is_prev_tag_ignored = false
      @is_html_mode = html_mode
    end

    def update_omissibility(omissibility=false)
      if @is_prev_tag_omissible
        if !omissibility
          @content << '>'
        end
        @is_prev_tag_omissible = false
      end
    end

    def is_html_elem(uri)
      # In HTML, HTML namespace would be omitted.
      # In XML, HTML namespace might (or might not) be omitted.
      uri.nil? || (!@is_html_mode && uri == HTML_NS)
    end

    def is_close_tag_omissible(name, uri)
      if is_html_elem(uri)
        case name.downcase
        when 'meta', 'link', 'br', 'hr'
          # HTML has some tags whose close tag should be omitted.
          true
        else
          # Basically HTML elements (like `a`, `i`, `script`, etc...)
          # are not allowed to omit close tag.
          false
        end
      else
        # Always true for non-HTML elements.
        true
      end
    end

    def escape_text(text)
      text.
        gsub(/&/, '&amp;').
        gsub(/</, '&lt;').
        gsub(/>/, '&gt;')
    end

    def escape_attr(text)
      text.
        gsub(/&/, '&amp;').
        gsub(/</, '&lt;').
        gsub(/>/, '&gt;').
        gsub(/"/, '&quot;').
        gsub(/'/, '&apos;')
    end

    # HTML parser calls this.
    def start_element(name, attrs=[])
      start_element_namespace(
        name,
        attrs.map {|name, value|
          ::Nokogiri::XML::SAX::Parser::Attribute.new(name, nil, nil, value)
        })
    end

    def start_element_namespace(name, attrs=[], prefix=nil, uri=nil, ns=[])
      if name.downcase == 'meta' && is_html_elem(uri)
        if attrs.any? {|attr| attr.localname == 'http-equiv' && attr.value.downcase == 'content-type' }
          # This node should be omitted.
          @is_prev_tag_ignored = true
          return
        end
      end
      update_omissibility
      @is_prev_tag_omissible = true
      @content << '<'
      if prefix
        @content << prefix << ':'
      end
      @content << name

      attrs.each do |attr|
        @content << ' '
        if attr.prefix
          @content << attr.prefix << ':'
        end
        @content << attr.localname << '="' << escape_attr(attr.value) << '"'
      end
    end

    # HTML parser calls this.
    def end_element(name)
      end_element_namespace(name)
    end

    def end_element_namespace(name, prefix=nil, uri=nil)
      if @is_prev_tag_ignored
        @is_prev_tag_ignored = false
        return
      end
      if @is_prev_tag_omissible
        if is_close_tag_omissible(name, uri)
          @content << ' />'
        else
          @content << "></#{name}>"
        end
      else
        @content << "</#{name}>"
      end
      @is_prev_tag_omissible = false
    end

    def cdata_block(text)
      if @is_prev_tag_ignored
        return
      end
      update_omissibility
      if @is_html_mode
        # Content inside `script` tag is treated as CDATA by
        # HTML parser, and the content would be already escaped.
        @content << text
      else
        @content << escape_text(text)
      end
    end

    def characters(text)
      if @is_prev_tag_ignored
        return
      end
      update_omissibility
      @content << escape_text(text)
    end

    def comment(text)
      if @is_prev_tag_ignored
        return
      end
      update_omissibility
      @content << '<!-- ' << text << '-->'
    end

    def processing_instruction(name, content)
      if @is_prev_tag_ignored
        return
      end
      # If `name.downcase == 'xml'`, it may be XML decleration.
      # Ignore it.
      if name.downcase != 'xml'
        update_omissibility
        @content << '<?' << name << ' ' << content << '?>'
      end
    end
  end

  class Xhtml5ize < Nanoc::Filter
    identifier :xhtml5ize
    requires 'nokogiri'

    def run(content, params = {})
      Nanoc::Extra::JRubyNokogiriWarner.check_and_warn

      in_type = params.fetch(:type, :html)
      #out = ::Nokogiri::XML::SAX::PushParser.new(Xhtml5Doc, nil, encoding = 'UTF-8')
      case in_type
      when :html
        # Write as XHTML because `::Nokogiri::HTML#to_xml` doesn't close `<meta>` tag...
        # Note that `to_xhtml` wraps some texts with CDATA section, which is not available for html5.
        xhtml5doc = Xhtml5Doc.new(true)
        parser = ::Nokogiri::HTML::SAX::Parser.new(xhtml5doc)
      when :xml, :xhtml
        xhtml5doc = Xhtml5Doc.new(false)
        parser = ::Nokogiri::XML::SAX::Parser.new(xhtml5doc)
      else
        raise "unknown syntax: #{type.inspect} (expected :html, :xhtml or :xml)"
      end
      parser.parse(content)
      xhtml5doc.content
    end
  end
end
