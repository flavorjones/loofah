# frozen_string_literal: true

require "helper"

class Html5TestSafelistProperties < Loofah::TestCase
  Loofah::HTML5::SafeList::SVG_ATTR_VAL_ALLOWS_REF.each do |attr_name|
    define_method "test_svg_attr_allow_ref_#{attr_name}_is_in_svg_attributes" do
      assert_includes(Loofah::HTML5::SafeList::SVG_ATTRIBUTES, attr_name)
    end
  end

  # Applications that permit these elements still get the local-reference restriction.
  SVG_ALLOW_LOCAL_HREF_OUTSIDE_SVG_ELEMENTS = ["font-face-uri"]

  (Loofah::HTML5::SafeList::SVG_ALLOW_LOCAL_HREF - SVG_ALLOW_LOCAL_HREF_OUTSIDE_SVG_ELEMENTS).each do |attr_name|
    define_method "test_svg_attr_allow_local_ref_#{attr_name}_is_in_svg_elements" do
      assert_includes(Loofah::HTML5::SafeList::SVG_ELEMENTS, attr_name)
    end
  end
  Loofah::HTML5::SafeList::SVG_ALLOW_LOCAL_HREF.each do |tag_name|
    define_method "test_svg_attr_allow_local_ref_#{tag_name}_matches_the_html5_parsed_element_name" do
      skip("html5 not supported") unless Loofah.html5_support?

      parsed_name = Nokogiri::HTML5.fragment("<svg><#{tag_name}></#{tag_name}></svg>").at_css("svg").element_children.first.name

      assert_includes(Loofah::HTML5::SafeList::SVG_ALLOW_LOCAL_HREF, parsed_name)
    end
  end
end
