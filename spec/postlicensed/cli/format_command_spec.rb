# frozen_string_literal: true

require "postlicensed/cli/format_command"

RSpec.describe Postlicensed::CLI::FormatCommand do
  subject(:format_command) { described_class.new }

  describe "#run" do
    let(:argv) { ["format", *options] }
    let(:format) { instance_double(Postlicensed::Format) }
    let(:format_result) { "test" }
    let(:default_target_dir) { ".licenses" }

    before do
      allow(Postlicensed::Format).to receive(:new).and_return(format)
      allow(format).to receive(:run).and_return(format_result)
    end

    context "when no options are given" do
      let(:options) { [] }

      it "handles the default directory" do
        suppress_stdout { format_command.run(argv) }
        expect(format).to have_received(:run).with(default_target_dir, update: false)
      end

      it "prints a result" do
        expect { format_command.run(argv) }.to output(format_result.pretty_inspect).to_stdout
      end
    end

    context "when --licensed-cache-dir is given" do
      let(:licensed_cache_dir) { "path/to/licensed_cache_dir" }
      let(:options) { ["--licensed-cache-dir", licensed_cache_dir] }

      it "handles the specified directory" do
        suppress_stdout { format_command.run(argv) }
        expect(format).to have_received(:run).with(licensed_cache_dir, update: false)
      end
    end

    context "when --update is given" do
      let(:options) { ["--update"] }

      it "edits files in-place" do
        aggregate_failures do
          expect { format_command.run(argv) }.not_to output.to_stdout
          expect(format).to have_received(:run).with(default_target_dir, update: true)
        end
      end
    end

    context "when --help is given" do
      let(:options) { ["--help"] }
      let(:expected_help_text) do
        <<~OUTPUT
          Usage: postlicensed format [options]

          Options:
                  --licensed-cache-dir DIR
                  --update
        OUTPUT
      end

      it "prints help text and exits" do
        expect { format_command.run(argv) }
          .to output(expected_help_text).to_stdout.and raise_error(SystemExit)
      end
    end
  end
end
