# frozen_string_literal: true

require "optparse"
require_relative "../program_name"
require_relative "../version"

module Postlicensed
  class CLI
    module Helper
      DEFAULT_LICENSED_CACHE_DIR = ".licenses"

      DEFAULT_LICENSED_CONFIG_PATH = ".licensed.yml"

      private_constant :DEFAULT_LICENSED_CACHE_DIR,
                       :DEFAULT_LICENSED_CONFIG_PATH

      private

      def initialize_option_parser
        parser = OptionParser.new
        parser.program_name = PROGRAM_NAME
        parser.version = VERSION
        parser
      end

      def make_usage_banner(examples)
        example1, *rest = Array(examples).flatten
        label = "Usage: "
        [
          label + example1,
          *rest.map { (" " * label.length) + _1 }
        ].join("\n")
      end

      def add_options(parser)
        parser.separator ""
        parser.separator "Options:"
        yield
      end
    end
  end
end
