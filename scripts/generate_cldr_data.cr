# This script generates the files in src/cldr/*
# that contains CLDR locale data for internationalization.

require "http/client"
require "json"
require "ecr"
require "compiler/crystal/formatter" # require "../src/compiler/crystal/formatter"

require "../src/cldr/version"

CLDR_ROOT = "https://raw.githubusercontent.com/unicode-cldr/"

class String
  def to_literal
    "\"#{gsub(/"\\/) { |char| "\\" + char }}\""
  end

  def to_hours
    hours, minutes = split(":", 2)
    hours.to_i.to_s
  end

  def to_minutes
    hours, minutes = split(":", 2)
    minutes.to_i.to_s
  end

  def ucfirst
    self[0].upcase + self[1..size - 1]
  end
end

struct Nil
  def to_literal
    "nil"
  end
end

class JAvailableLocales
  JSON.mapping(
    modern: {type: Array(String)},
    full: {type: Array(String)},
  )
end

class JLanguageAliasJson
  JSON.mapping(
    reason: {type: String, key: "_reason"},
    replacement: {type: String, key: "_replacement"},
  )
end

alias JLanguageAlias = Hash(String, JLanguageAliasJson)

class JAlias
  JSON.mapping(
    language_alias: {type: JLanguageAlias, key: "languageAlias"},
  )
end

class JMetadataAliases
  JSON.mapping(
    alias: {type: JAlias},
  )
end

class JSupplementalAliases
  JSON.mapping(
    metadata: {type: JMetadataAliases},
  )
end

class JCalendarDataEntry
  JSON.mapping(
    calendar_system: {type: String, key: "calendarSystem", default: "none"},
    eras: {type: Hash(String, Hash(String, String)), default: Hash(String, Hash(String, String)).new},
  )
end

class JSupplementalCalendarData
  JSON.mapping(
    calendar_data: {type: Hash(String, JCalendarDataEntry), key: "calendarData"},
  )
end

class JSupplementalCalendarPreferenceData
  JSON.mapping(
    calendar_preference_data: {type: Hash(String, String), key: "calendarPreferenceData"},
  )
end

class JCurrencyData
  JSON.mapping(
    fractions: {type: Hash(String, Hash(String, String))},
  )
end

class JSupplementalCurrencyData
  JSON.mapping(
    currency_data: {type: JCurrencyData, key: "currencyData"},
  )
end

class JGender
  JSON.mapping(
    person_list: {type: Hash(String, String), key: "personList"},
  )
end

class JSupplementalGender
  JSON.mapping(
    gender: {type: JGender},
  )
end

class JSupplementalNumberingSystems
  JSON.mapping(
    numbering_systems: {type: Hash(String, Hash(String, String)), key: "numberingSystems"},
  )
end

class JSupplementalDayPeriods
  JSON.mapping(
    day_periods: {type: Hash(String, Hash(String, Hash(String, String))), key: "dayPeriodRuleSet"},
  )
end

class JSupplementalLanguageData
  JSON.mapping(
    language_data: {type: Hash(String, Hash(String, Array(String))), key: "languageData"},
  )
end

def get_json(repo, path)
  if File.readable?("datasource/#{repo}/#{path}.json")
    return File.read("datasource/#{repo}/#{path}.json")
  end
  url = "#{CLDR_ROOT}#{repo}/#{Cldr::CLDR_VERSION}/#{path}.json"
  HTTP::Client.get(url).body
end

def get_supplemental(name)
  get_json "cldr-core", "supplemental/#{name}"
end

body = get_json "cldr-core", "availableLocales"
available_locales = JAvailableLocales.from_json(body, root: "availableLocales")

language_alias = JSupplementalAliases.from_json(get_supplemental("aliases"), root: "supplemental").metadata.alias.language_alias
calendar_data = JSupplementalCalendarData.from_json(get_supplemental("calendarData"), root: "supplemental").calendar_data
calendar_preference_data = JSupplementalCalendarPreferenceData.from_json(get_supplemental("calendarPreferenceData"), root: "supplemental").calendar_preference_data
currency_data = JSupplementalCurrencyData.from_json(get_supplemental("currencyData"), root: "supplemental").currency_data
gender = JSupplementalGender.from_json(get_supplemental("gender"), root: "supplemental").gender
numbering_systems = JSupplementalNumberingSystems.from_json(get_supplemental("numberingSystems"), root: "supplemental").numbering_systems
day_periods = JSupplementalDayPeriods.from_json(get_supplemental("dayPeriods"), root: "supplemental").day_periods
language_data = JSupplementalLanguageData.from_json(get_supplemental("languageData"), root: "supplemental").language_data

output = String.build do |str|
  ECR.embed "#{__DIR__}/core.ecr", str
end
output = Crystal.format(output)
File.write("#{__DIR__}/../src/cldr/core.cr", output)
