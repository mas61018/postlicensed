# frozen_string_literal: true

require "yaml"
require_relative "../diff"
require_relative "../program_name"
require_relative "helper"

module Postlicensed
  class CLI
    class DiffCommand
      include Helper

      DEFAULT_PACKAGE_LOCK_PATH = "package-lock.json"

      USAGE = [
        "#{PROGRAM_NAME} diff <bundled-file> --license-checker [options]",
        "#{PROGRAM_NAME} diff <bundled-file> --package-lock [path] [options]"
      ].freeze

      #: (?Array[String]) -> void
      def run(argv = ARGV)
        bundled_file_path = argv[1]
        parser, params = parse_arguments(argv)
        return if bundled_file_path && main(bundled_file_path, params)

        puts parser.help
        exit(false)
      end

      private

      #: (Array[String]) -> [OptionParser, Hash[Symbol, untyped]]
      def parse_arguments(argv)
        params = {
          license_checker: false,
          package_lock: false,
          package_lock_path: DEFAULT_PACKAGE_LOCK_PATH
        }

        parser = initialize_option_parser
        parser.banner = make_usage_banner(USAGE)
        add_options(parser) do
          parser.on("--license-checker") { params[:license_checker] = true }
          parser.on("--licensed-config PATH") { |path| params[:licensed_config_path] = path }
          parser.on("--package-lock [PATH]") do |path|
            params[:package_lock] = true
            params[:package_lock_path] = path if path
          end
        end
        parser.parse(argv)

        [parser, params]
      end

      #: (?String?) -> Array[untyped]
      def load_licensed_ignore(licensed_config_path = nil)
        if licensed_config_path.nil?
          return [] unless File.exist?(DEFAULT_LICENSED_CONFIG_PATH)

          licensed_config_path = DEFAULT_LICENSED_CONFIG_PATH
        end

        config = YAML.load_file(licensed_config_path)
        ignored = config["ignored"]
        return [] unless ignored.is_a?(Hash)

        ignored.values.flatten.compact
      end

      #: (String, Hash[Symbol, untyped]) -> String?
      def main(bundled_file_path, params)
        licensed_ignore = load_licensed_ignore(params[:licensed_config_path])
        result = if params[:license_checker]
                   Diff.new.compare_with_license_checker_result(bundled_file_path, licensed_ignore)
                 elsif params[:package_lock]
                   Diff.new.compare_with_package_lock(bundled_file_path, params[:package_lock_path], licensed_ignore)
                 end
        puts result if result
        result
      end
    end
  end
end
