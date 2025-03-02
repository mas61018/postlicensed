# frozen_string_literal: true

require_relative "../format"
require_relative "../program_name"
require_relative "helper"

module Postlicensed
  class CLI
    class FormatCommand
      include Helper

      USAGE = "#{PROGRAM_NAME} format [options]".freeze

      #: (?Array[String]) -> void
      def run(argv = ARGV)
        params = parse_arguments(argv)
        result = Format.new.run(params[:licensed_cache_dir], **params.slice(:update))
        pp result unless params[:update]
      end

      private

      #: (Array[String]) -> Hash[Symbol, untyped]
      def parse_arguments(argv)
        params = {
          licensed_cache_dir: DEFAULT_LICENSED_CACHE_DIR,
          update: false
        }

        parser = initialize_option_parser
        parser.banner = make_usage_banner(USAGE)
        add_options(parser) do
          parser.on("--licensed-cache-dir DIR") { |dir| params[:licensed_cache_dir] = dir }
          parser.on("--update") { params[:update] = true }
        end
        parser.parse(argv)

        params
      end
    end
  end
end
