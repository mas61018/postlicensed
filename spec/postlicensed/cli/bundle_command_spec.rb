# frozen_string_literal: true

require "postlicensed/cli/bundle_command"

RSpec.describe Postlicensed::CLI::BundleCommand do
  subject(:bundle_command) { described_class.new }

  describe "#run" do
    let(:argv) { ["bundle", *options] }
    let(:bundle) { instance_double(Postlicensed::Bundle) }
    let(:bundle_result) { "test" }
    let(:default_target_dir) { ".licenses" }

    before do
      allow(Postlicensed::Bundle).to receive(:new).and_return(bundle)
      allow(bundle).to receive(:run).and_return(bundle_result)
    end

    context "when no options are given" do
      let(:options) { [] }

      it "handles the default directory" do
        suppress_stdout { bundle_command.run(argv) }
        expect(bundle).to have_received(:run).with(default_target_dir, nil)
      end

      it "prints a result" do
        expect { bundle_command.run(argv) }.to output("#{bundle_result}\n").to_stdout
      end
    end

    context "when --licensed-cache-dir is given" do
      let(:licensed_cache_dir) { "path/to/licensed_cache_dir" }
      let(:options) { ["--licensed-cache-dir", licensed_cache_dir] }

      it "handles the specified directory" do
        suppress_stdout { bundle_command.run(argv) }
        expect(bundle).to have_received(:run).with(licensed_cache_dir, nil)
      end
    end

    context "when -o is given" do
      let(:output_file_path) { "path/to/output_file" }
      let(:options) { ["-o", output_file_path] }

      it "outputs a result to the specified path instead of stdout" do
        aggregate_failures do
          expect { bundle_command.run(argv) }.not_to output.to_stdout
          expect(bundle).to have_received(:run).with(default_target_dir, output_file_path)
        end
      end
    end

    context "when --output is given" do
      let(:output_file_path) { "path/to/output_file" }
      let(:options) { ["--output", output_file_path] }

      it "outputs a result to the specified path instead of stdout" do
        aggregate_failures do
          expect { bundle_command.run(argv) }.not_to output.to_stdout
          expect(bundle).to have_received(:run).with(default_target_dir, output_file_path)
        end
      end
    end

    context "when --help is given" do
      let(:options) { ["--help"] }
      let(:expected_help_text) do
        <<~OUTPUT
          Usage: postlicensed bundle [options]

          Options:
                  --licensed-cache-dir DIR
              -o, --output FILE
        OUTPUT
      end

      it "prints help text and exits" do
        expect { bundle_command.run(argv) }
          .to output(expected_help_text).to_stdout.and raise_error(SystemExit)
      end
    end
  end
end
