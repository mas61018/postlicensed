# frozen_string_literal: true

require_relative "../bundle"
require_relative "../program_name"
require_relative "helper"

module Postlicensed
  class CLI
    class BundleCommand
      include Helper

      USAGE = "#{PROGRAM_NAME} bundle [options]".freeze

      def run(argv = ARGV)
        parser = initialize_option_parser
        params = add_bundle_params_handler(parser)
        parser.parse(argv)
        result = Bundle.new.run(params[:licensed_cache_dir], params[:output_file_path])
        puts result unless params[:output_file_path]
      end

      private

      def add_bundle_params_handler(parser)
        params = { licensed_cache_dir: DEFAULT_LICENSED_CACHE_DIR }
        parser.banner = make_usage_banner(USAGE)
        add_options(parser) do
          parser.on("--licensed-cache-dir DIR") { |dir| params[:licensed_cache_dir] = dir }
          parser.on("-o", "--output FILE") { |file| params[:output_file_path] = file }
        end
        params
      end
    end
  end
end
