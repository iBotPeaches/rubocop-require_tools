# frozen_string_literal: true

module Spaceship
  module ConnectAPI
    module AppScreenshotSet
      # This module mimics the Fastlane structure where a deep constant is defined
      # and later aliased to a short name in a different file.
      module DisplayType
        ALL_IMESSAGE = [
          'imessage_iphone',
          'imessage_ipad'
        ].freeze

        APP_IPHONE_40 = 'app_iphone_40'
        APP_IPAD_PRO_129 = 'app_ipad_pro_129'
      end
    end
  end
end
