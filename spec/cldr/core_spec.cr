require "../spec_helper"

describe Cldr::Core do
  it "should have available locales" do
    Cldr::Core.available_locales.modern.any? { |lang| lang == "en" }.should be_true
    Cldr::Core.available_locales.modern.bsearch { |lang| lang >= "en" }.should eq "en"
    Cldr::Core.available_locales.modern.bsearch { |lang| lang >= "agq" }.should_not eq "agq"
    Cldr::Core.available_locales.full.bsearch { |lang| lang >= "agq" }.should eq "agq"
  end

  it "should have supplemental.metadata.alias.language_alias" do
    Cldr::Core.supplemental.metadata.alias.language_alias["aar"].reason.overlong?.should be_true
    Cldr::Core.supplemental.metadata.alias.language_alias["aar"].replacement.should eq "aa"
  end

  it "should have supplemental.calendar_data.japanese.calendar_system" do
    Cldr::Core.supplemental.calendar_data.japanese.calendar_system.solar?.should be_true
  end

  it "should have supplemental.calendar_data.japanese.calendar_system" do
    Cldr::Core.supplemental.calendar_preference_data["001"].should eq [ Cldr::Core.supplemental.calendar_data.gregorian ]
  end

  it "should have supplemental.currency_data[\"DEFAULT\"]" do
    Cldr::Core.supplemental.currency_data.fractions["DEFAULT"]?.should_not be_nil
  end

  it "should have supplemental.gender.person_list[\"ar\"]" do
    Cldr::Core.supplemental.gender.person_list["ar"].male_taints?.should be_true
  end

  it "should have supplemental.numbering_systems[\"latn\"]" do
    Cldr::Core.supplemental.numbering_systems["latn"].type.numeric?.should be_true
    Cldr::Core.supplemental.numbering_systems["latn"].digits.should eq("0123456789")
  end
end
