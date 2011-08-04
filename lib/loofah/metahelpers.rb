module Loofah
  module MetaHelpers
    def self.HashifiedConstants(orig_module)
      hashed_module = Module.new
      orig_module.constants.each do |constant|
        next unless orig_module.module_eval("#{constant}").is_a?(Set)
        hashed_module.module_eval <<-CODE
          #{constant} = Set.new
          #{orig_module.name}::#{constant}.each do |c|
            #{constant}.add c 
            #{constant}.add c.downcase
          end
        CODE
      end
      hashed_module
    end
  end
end
