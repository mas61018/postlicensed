# frozen_string_literal: true

require_relative "../bundle"
require_relative "../program_name"
require_relative "helper"

module Postlicensed
  class CLI
    class BundleCommand
      include Helper

      USAGE = "#{PROGRAM_NAME} bundle [options]".freeze

      #: (?Array[String]) -> void
      def run(argv = ARGV)
        params = parse_arguments(argv)
        result = Bundle.new.run(params[:licensed_cache_dir], params[:output_file_path])
        puts result unless params[:output_file_path]
      end

      private

      #: (Array[String]) -> Hash[Symbol, untyped]
      def parse_arguments(argv)
        params = { licensed_cache_dir: DEFAULT_LICENSED_CACHE_DIR }

        parser = initialize_option_parser
        parser.banner = make_usage_banner(USAGE)
        add_options(parser) do
          parser.on("--licensed-cache-dir DIR") { |dir| params[:licensed_cache_dir] = dir }
          parser.on("-o", "--output FILE") { |file| params[:output_file_path] = file }
        end
        parser.parse(argv)

        params
      end
    end
  end
end
