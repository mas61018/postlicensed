# frozen_string_literal: true

require "postlicensed/cli/helper"

RSpec.describe Postlicensed::CLI::Helper do
  let(:object) { Object.new.extend(described_class) }

  describe "#initialize_option_parser" do
    it "returns an option parser assigned this program's name and version" do
      parser = object.send(:initialize_option_parser)
      expect(parser.ver).to eq "postlicensed #{Postlicensed::VERSION}"
    end
  end

  describe "#make_usage_banner" do
    let(:examples) { ["test foo [options]", "test bar [options]"] }
    let(:expected_usage_banner) do
      <<~BANNER.chomp
        Usage: test foo [options]
               test bar [options]
      BANNER
    end

    it "returns a usage banner" do
      expect(object.send(:make_usage_banner, examples)).to eq expected_usage_banner
    end
  end

  describe "#add_options" do
    it "creates a section of options" do
      parser = OptionParser.new
      parser.banner = "Usage: test [options]"
      object.send(:add_options, parser) do
        parser.on("-a")
        parser.on("-b")
      end
      expect(parser.help).to eq <<~HELP
        Usage: test [options]

        Options:
            -a
            -b
      HELP
    end
  end
end
