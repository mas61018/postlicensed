# frozen_string_literal: true

require_relative "cli/bundle_command"
require_relative "cli/diff_command"
require_relative "cli/format_command"
require_relative "cli/helper"

module Postlicensed
  class CLI
    include Helper

    COMMANDS = {
      "bundle" => BundleCommand,
      "diff" => DiffCommand,
      "format" => FormatCommand
    }.freeze

    def run(argv = ARGV)
      command = COMMANDS[argv.first]

      if command.nil?
        puts make_usage_banner(COMMANDS.values.map { _1.const_get(:USAGE) })
        exit(false)
      end

      command.new.run(argv)
    end
  end
end
