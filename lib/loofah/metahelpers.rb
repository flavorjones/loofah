module Loofah
  module MetaHelpers
    def self.HashifiedConstants(orig_module)
      hashed_module = Module.new
      orig_module.constants.each do |constant|
        next unless orig_module.module_eval("#{constant}").is_a?(Array)
        hashed_module.module_eval <<-CODE
          #{constant} = {}
          #{orig_module.name}::#{constant}.each { |c| #{constant}[c] = true ; #{constant}[c.downcase] = true }
        CODE
      end
      hashed_module
    end
  end
end
