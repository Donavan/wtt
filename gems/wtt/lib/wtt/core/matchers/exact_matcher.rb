require 'wtt/core'
require 'rake'

# Top level namespace for What to Test
module WTT
  # Functionality core to WTT belongs here
  module Core
    module Matchers
      # Matches the extact line that changed
      class Exact
        def match(spectra, lineno)
          true if spectra.include?(lineno) || lineno == 0
        end
      end
    end
  end
end
