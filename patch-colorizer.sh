#!/bin/sh
set -eu

cd "$(dirname "$(readlink -f "$0")")"

NANOC_PATH="$(realpath --relative-to=. "$(bundle show nanoc)")"
echo "nanoc-path: ${NANOC_PATH}"

patch -p0 <<__EOF__
diff -Naur ${NANOC_PATH}/lib/nanoc/filters/colorize_syntax.rb ${NANOC_PATH}/lib/nanoc/filters/colorize_syntax.rb
--- ${NANOC_PATH}/lib/nanoc/filters/colorize_syntax.rb	2018-09-13 01:23:19.096066864 +0900
+++ ${NANOC_PATH}/lib/nanoc/filters/colorize_syntax.rb	2018-09-13 01:28:32.179975348 +0900
@@ -21,8 +21,8 @@
 
       # Colorize
       doc = parse(content, parser, params.fetch(:is_fullpage, false))
-      selector = params[:outside_pre] ? 'code' : 'pre > code'
-      doc.css(selector).each do |element|
+      selector = params[:outside_pre] ? './/*[local-name()="code"]' : './/*[local-name()="pre"]/*[local-name()="code"]'
+      doc.xpath(selector).each do |element|
         # Get language
         extracted_language = extract_language(element)
 
__EOF__
