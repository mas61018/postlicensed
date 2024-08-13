# frozen_string_literal: true

require "postlicensed/cli"

RSpec.describe Postlicensed::CLI do
  subject(:cli) { described_class.new }

  describe "#run" do
    shared_examples "execute command" do |command_class, argv|
      let(:command) { instance_double(command_class) }

      before do
        allow(command_class).to receive(:new).and_return(command)
      end

      it "executes the specified command" do
        expect(command).to receive(:run).with(argv)
        cli.run(argv)
      end
    end

    it_behaves_like "execute command", Postlicensed::CLI::BundleCommand, %w[bundle test_arg_1]
    it_behaves_like "execute command", Postlicensed::CLI::DiffCommand, %w[diff test_arg_2]
    it_behaves_like "execute command", Postlicensed::CLI::FormatCommand, %w[format test_arg_3]

    shared_examples "print usage" do |argv|
      let(:expected_usage) do
        pattern1 = "Usage: postlicensed .*\n"
        pattern2 = "       postlicensed .*\n"
        /\A#{pattern1}(#{pattern2})*\z/
      end

      it "prints how to use this program and exits" do
        expect { cli.run(argv) }.to output(expected_usage).to_stdout.and raise_error(SystemExit)
      end
    end

    context "when an unknown command is given" do
      it_behaves_like "print usage", ["abc"]
    end

    context "when no command is given" do
      it_behaves_like "print usage", []
    end
  end
end
