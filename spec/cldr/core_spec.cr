require "../spec_helper"

describe Cldr::Core do
  it "should have available locales" do
    Cldr::Core.available_locales.modern.empty?.should be_false
    Cldr::Core.available_locales.full.empty?.should be_false
  end
end
