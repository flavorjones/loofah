module Loofah
  module Elements
    # Block elements in HTML4
    STRICT_BLOCK_LEVEL = %w[address blockquote center dir div dl
      fieldset form h1 h2 h3 h4 h5 h6 hr isindex menu noframes
      noscript ol p pre table ul]

    # The following elements may also be considered block-level elements since they may contain block-level elements
    LOOSE_BLOCK_LEVEL = %w[dd dt frameset li tbody td tfoot th thead tr]

    BLOCK_LEVEL = STRICT_BLOCK_LEVEL + LOOSE_BLOCK_LEVEL
  end

  module HashedElements
    include Loofah::MetaHelpers::HashifiedConstants(Elements)
  end
end


