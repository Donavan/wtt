require 'wtt/core'
require 'rake'

# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    module Matchers
      # Matches if the line that changed is within "spread" distance
      class Fuzzy
        def initialize(spread=11)
          @spread = spread
        end

        def match(spectra, lineno)
          true if spectra.any? { |v| (v - lineno).abs <= @spread } || lineno == 0
        end
      end
    end
  end
end
