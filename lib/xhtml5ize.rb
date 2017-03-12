module Larry
  class Xhtml5ize < Nanoc::Filter
    identifier :xhtml5ize
    requires 'nokogiri'

    def run(content, params = {})
      Nanoc::Extra::JRubyNokogiriWarner.check_and_warn
      #cond_html_elem = '[namespace-uri()="http://www.w3.org/1999/xhtml"]'
      cond_html_elem = '[namespace-uri()="http://www.w3.org/1999/xhtml" or namespace-uri()=""]'

      in_type = params.fetch(:type, :html)
      case in_type
      when :html
        # Write as XHTML because `::Nokogiri::HTML#to_xml` doesn't close `<meta>` tag...
        # Note that `to_xhtml` wraps some texts with CDATA section, which is not available for html5.
        xml_content = ::Nokogiri::HTML(content, nil, 'utf-8').to_xhtml
      when :xml, :xhtml
        xml_content = content
      else
        raise "unknown syntax: #{type.inspect} (expected :html, :xhtml or :xml)"
      end
      xml_doc = ::Nokogiri::XML(xml_content, nil, 'utf-8')

      # Remove `<meta http-equiv="Content-Type" ... />` element.
      meta_content_type_selector = "//*[local-name()='meta']#{cond_html_elem}[@http-equiv]"
      xml_doc.xpath(meta_content_type_selector).each do |node|
        if node.attribute('http-equiv').value.downcase == 'content-type'
          # Remove previous blank text node if exists.
          prev_node = node.previous
          if prev_node && prev_node.text? && prev_node.blank?
            prev_node.remove
          end
          # Remove `meta` element.
          node.remove
        end
      end

      # Insert `//\n` to empty `script` element to prevent putting Nokogiri to output `<script ... />`.
      # (HTML5 does not allow `script` elements to omit close tags.
      # `Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS` also prevents this.
      #empty_script_selector = "//*[local-name()='script']#{cond_html_elem}[not(node())]"
      #xml_doc.xpath(empty_script_selector).each do |node|
      #  # `script` with `@src` can contain JS comments.
      #  # See https://www.w3.org/TR/2014/REC-html5-20141028/scripting-1.html#script-documentation .
      #  node.content = "//\n"
      #end

      # Replace CDATA section with (escaped) plain text.
      replace_cdata(xml_doc)

      #xml_doc.to_xml(save_with: ::Nokogiri::XML::Node::SaveOptions::NO_DECLARATION)
      serialized_doc = xml_doc.to_xml(save_with: ::Nokogiri::XML::Node::SaveOptions::new.no_declaration.no_empty_tags)

      # Omit close tags which are not allowed in HTML5.
      serialized_doc.gsub(/><\/(?:meta|link|br|hr)>/, ' />')
    end

    def replace_cdata(node, doc=node)
      node.children.each do |child|
        if child.cdata?
          child.replace(doc.create_text_node(child.content))
        elsif child.element?
          replace_cdata(child, doc)
        end
      end
    end
  end
end
