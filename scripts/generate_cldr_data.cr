# This script generates the file src/cldr/data.cr
# that contains CLDR locale data for internationalization.

require "http/client"
require "json"
require "ecr"
require "../src/compiler/crystal/formatter"

VERSION = "31.0.1"
CLDR_ROOT = "https://raw.githubusercontent.com/unicode-cldr/"

class AvailableLocales
  JSON.mapping(
    modern: { type: Array(String) },
    full: { type: Array(String) },
  )
end


def get_supplemental(name)
  url = "#{CLDR_ROOT}cldr-core/#{VERSION}/supplemental/#{name}"
  HTTP::Client.get(url).body
end

def get_available_locales
  url = "#{CLDR_ROOT}cldr-core/#{VERSION}/availableLocales.json"
  body = HTTP::Client.get(url).body
  AvailableLocales.from_json(body, root: "availableLocales")
end


available_locales = get_available_locales

class String
  def to_crystal_string_literal
    "\"" + gsub(/"\\/) { |char| "\\" + char } + "\""
  end
end

output = String.build do |str|
  ECR.embed "#{__DIR__}/core.ecr", str
end
output = Crystal.format(output)
File.write("#{__DIR__}/../src/cldr/core.cr", output)
