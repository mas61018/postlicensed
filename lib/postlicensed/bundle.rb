# frozen_string_literal: true

require "digest/sha1"
require "json"
require "yaml"
require_relative "package_comparator"

module Postlicensed
  class Bundle
    def run(licensed_cache_dir, output_file_path = nil)
      packages = load_yamls(licensed_cache_dir).map { format(_1) }
      license_texts = normalize!(packages)
      result = JSON.pretty_generate({ "packages" => packages.sort(&PackageComparator.new),
                                      "licenseTexts" => license_texts.sort_by { |k, _v| k }.to_h })
      File.write(output_file_path, result) if output_file_path
      result
    end

    private

    def load_yamls(dir)
      Dir.glob(File.join(dir, "**", "*.yml"))
         .map { YAML.load_file(_1) }
    end

    def format(yaml_data)
      license_type = yaml_data["license"]
      licenses = yaml_data["licenses"]
      license_text = (licenses.find { _1["sources"] =~ /license/i } || licenses.first)&.dig("text")
      yaml_data.slice("name", "version")
               .merge({ "license" => { "type" => license_type,
                                       :temporary_license_text_key => license_text } })
    end

    def normalize!(packages)
      license_texts = {}

      packages.each do |package|
        license = package["license"]
        license_text = license.delete(:temporary_license_text_key)
        license["digest"] = if license_text
                              Digest::SHA1.hexdigest(license_text).tap { license_texts[_1] = license_text }
                            end
      end

      license_texts
    end
  end
end
