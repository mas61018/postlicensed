# frozen_string_literal: true

require "yaml"
require_relative "format/license_text_formatter"

module Postlicensed
  class Format
    def initialize
      @license_text_formatter = LicenseTextFormatter.new
    end

    def run(licensed_cache_dir, update: false)
      result = load_yamls(licensed_cache_dir)
               .transform_values { |yaml_data| YAML.dump(format_yaml_data(yaml_data)) }
      result.each { |path, text| File.write(path, text) } if update
      result
    end

    private

    def load_yamls(dir)
      Dir.glob(File.join(dir, "**", "*.yml"))
         .each_with_object({}) { |path, hash| hash[path] = YAML.load_file(path) }
    end

    def format_yaml_data(yaml_data)
      licenses = yaml_data["licenses"].map do |license|
        next license unless /license/i.match?(license["sources"])

        license.merge({ "text" => @license_text_formatter.format(license["text"]) })
      end
      yaml_data.merge({ "licenses" => licenses })
    end
  end
end
