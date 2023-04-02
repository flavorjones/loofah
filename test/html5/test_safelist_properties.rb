# frozen_string_literal: true

require "helper"

class Html5TestSafelistProperties < Loofah::TestCase
  Loofah::HTML5::SafeList::SVG_ATTR_VAL_ALLOWS_REF.each do |attr_name|
    define_method "test_svg_attr_allow_ref_#{attr_name}_is_in_svg_attributes" do
      assert_includes(Loofah::HTML5::SafeList::SVG_ATTRIBUTES, attr_name)
    end
  end

  Loofah::HTML5::SafeList::SVG_ALLOW_LOCAL_HREF.each do |attr_name|
    define_method "test_svg_attr_allow_local_ref_#{attr_name}_is_in_svg_elements" do
      assert_includes(Loofah::HTML5::SafeList::SVG_ELEMENTS, attr_name)
    end
  end
end
