# This is a monkey-patch to HTTParty because the AP API doesn't return the HTML in the <content>
# tag in CDATA tags, so we need to gsub the response to add them before being parsed
class HTTParty::Parser
  SupportedFormats.merge!(
    {
      'text/xml'               => :ap_xml,
      'application/xml'        => :ap_xml
    }
  )
  
  # Fixes and parses the XML returned by the AP
  # Why is it broken? The HTML content doesn't include CDATA tags
  def ap_xml
    # other gsub could be negaitve /<content?([A-Za-z "=]+)>(?!<\!\[CDATA\[)/
    # but CS theory says that isn't a good idea, and so does running time tests
    Crack::XML.parse(body.gsub(/<content?([A-Za-z "=]+)><\!\[CDATA\[/, '<content>').gsub(/\]\]><\/content>/, "</content>").gsub(/<content?([A-Za-z "=]+)>/, "<content><![CDATA[").gsub(/<\/content>/, "]]></content>"))
    # Crack::XML.parse(body.gsub(/<content?([A-Za-z "=]+)>(?!<\!\[CDATA\[)/, "<content><![CDATA[").gsub(/<\/content>/, "]]></content>"))
  end
end