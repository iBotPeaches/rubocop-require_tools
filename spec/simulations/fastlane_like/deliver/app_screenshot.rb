# frozen_string_literal: true

# This file simulates an app-side consumer that requires a deep library file,
# creates a short alias for a nested constant, and then uses nested members
# through that alias (mirroring Fastlane's DisplayType pattern).

require_relative '../lib/spaceship/connect_api/app_screenshot_set/display_type'

# Create a short alias for a deeply nested constant
DisplayType = Spaceship::ConnectAPI::AppScreenshotSet::DisplayType

# Use constants through the alias. The cop should consider these resolved
# because the defining file was required above and the alias is established.
DisplayType::ALL_IMESSAGE
DisplayType::APP_IPHONE_40
DisplayType::APP_IPAD_PRO_129

# Also reference the alias name itself as a namespace (should not be an offense)
DisplayType
