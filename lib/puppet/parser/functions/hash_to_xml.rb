require 'xmlsimple'

def fix_element element

    if element.has_attributes?
        sorted_attrs = element.attributes.sort_by { |x| x[0] }

        element.attributes.each do |a|
            element.delete_attribute a[0]
        end

        sorted_attrs.each do |a|
            element.add_attribute(a[0],a[1])
        end
    end

    if element.has_elements?
        sorted_child_elements = element.elements.sort_by { |x| x.xpath }

        element.elements.each do |e|
            element.delete_element e
        end

        sorted_child_elements.each do |e|
            element.add_element e
            fix_element e
        end
    end
end

def fix_xml xml
    out = ""
    fix_element xml.elements.first
    xml.write(out,4)
    out
end

Puppet::Parser::Functions.newfunction(:hash_to_xml, :type => :rvalue, :doc =>
  "Function that converts a hash to an XML string") do |args|
  if args.length < 1 or args.length > 2
    raise Puppet::Error, "#hash_to_xml accepts only one (1) or two (2) arguments, you passed #{args.length}"
  end

  args.each do |arg|
    if arg.class != Hash
      raise Puppet::Error, "#hash_to_xml requires a hash for argument, you passed a #{arg.class}"
    end
  end

  if args.length == 1
    x = REXML::Document.new XmlSimple.xml_out(args[0])
  else
    x = REXML::Document.new XmlSimple.xml_out(args[0],args[1])
  end

  fix_xml(x)
end
