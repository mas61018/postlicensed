# frozen_string_literal: true

require "yaml"
require_relative "format/license_text_formatter"

module Postlicensed
  class Format
    # @rbs @license_text_formatter: LicenseTextFormatter

    def initialize
      @license_text_formatter = LicenseTextFormatter.new
    end

    #: (String, ?update: bool) -> Hash[String, String]
    def run(licensed_cache_dir, update: false)
      result = load_yamls(licensed_cache_dir)
               .transform_values { |yaml_data| YAML.dump(format_yaml_data(yaml_data)) }
      result.each { |path, text| File.write(path, text) } if update
      result
    end

    private

    #: (String) -> Hash[String, untyped]
    def load_yamls(dir)
      hash = {} #: Hash[String, untyped]

      Dir.glob(File.join(dir, "**", "*.yml")).each do |path|
        hash[path] = YAML.load_file(path)
      end

      hash
    end

    #: (untyped) -> untyped
    def format_yaml_data(yaml_data)
      licenses = yaml_data["licenses"].map do |license|
        next license unless /license/i.match?(license["sources"])

        license.merge({ "text" => @license_text_formatter.format(license["text"]) })
      end
      yaml_data.merge({ "licenses" => licenses })
    end
  end
end
