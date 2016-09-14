module RailsModuleUnification
  module Refinement
    refine Object do
      def const_missing(name)
        binding.pry
        super
      rescue
        binding.pry
        name
      end
    end
  end
end
