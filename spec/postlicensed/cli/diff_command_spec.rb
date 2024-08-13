# frozen_string_literal: true

require "postlicensed/cli/diff_command"
require "tmpdir"

RSpec.describe Postlicensed::CLI::DiffCommand do
  subject(:diff_command) { described_class.new }

  describe "#run" do
    let(:diff) { instance_double(Postlicensed::Diff) }

    before do
      allow(Postlicensed::Diff).to receive(:new).and_return(diff)
    end

    shared_context "cd project root" do
      let(:licensed_config) { {} }

      around(:example) do |ex|
        Dir.mktmpdir do |tmpdir|
          File.write(File.join(tmpdir, ".licensed.yml"), YAML.dump(licensed_config))
          Dir.chdir(tmpdir) do
            ex.run
          end
        end
      end
    end

    context "when --license-checker is given" do
      let(:bundled_file_path) { "path/to/bundled_file" }
      let(:argv) { ["diff", bundled_file_path, "--license-checker"] }
      let(:diff_result) { "test\n" }

      before do
        allow(diff).to receive(:compare_with_license_checker_result).and_return(diff_result)
      end

      it "compares the bundled file with the result of license-checker" do
        aggregate_failures do
          expect { diff_command.run(argv) }.to output(diff_result).to_stdout
          expect(diff).to have_received(:compare_with_license_checker_result).with(bundled_file_path, [])
        end
      end

      context "when --licensed-config is given" do
        let(:argv) { [*super(), "--licensed-config", fixture_path(".licensed.yml")] }

        it "loads the package names ignored by Licensed from the specified file" do
          suppress_stdout { diff_command.run(argv) }
          expect(diff).to have_received(:compare_with_license_checker_result).with(bundled_file_path, ["baz"])
        end
      end

      context "when a config file of Licensed exists at the default path" do
        include_context "cd project root" do
          let(:ignored_package_names) { %w[test1 test2] }
          let(:licensed_config) { { "ignored" => { "npm" => ignored_package_names } } }
        end

        it "loads the package names ignored by Licensed from that file" do
          suppress_stdout { diff_command.run(argv) }
          expect(diff).to have_received(:compare_with_license_checker_result).with(bundled_file_path,
                                                                                   ignored_package_names)
        end
      end
    end

    context "when --package-lock is given" do
      let(:bundled_file_path) { "path/to/bundled_file" }
      let(:package_lock_path) { "path/to/package_lock" }
      let(:argv) { ["diff", bundled_file_path, "--package-lock", package_lock_path] }
      let(:diff_result) { "test\n" }

      before do
        allow(diff).to receive(:compare_with_package_lock).and_return(diff_result)
      end

      it "compares the bundled file with the package-lock file" do
        aggregate_failures do
          expect { diff_command.run(argv) }.to output(diff_result).to_stdout
          expect(diff).to have_received(:compare_with_package_lock).with(bundled_file_path, package_lock_path, [])
        end
      end

      context "but a package-lock file path is omitted" do
        let(:argv) { ["diff", bundled_file_path, "--package-lock"] }

        it "handles the default package-lock file path" do
          suppress_stdout { diff_command.run(argv) }
          expect(diff).to have_received(:compare_with_package_lock).with(bundled_file_path, "package-lock.json", [])
        end
      end

      context "when --licensed-config is given" do
        let(:argv) { [*super(), "--licensed-config", fixture_path(".licensed.yml")] }

        it "loads the package names ignored by Licensed from the specified file" do
          suppress_stdout { diff_command.run(argv) }
          expect(diff).to have_received(:compare_with_package_lock).with(bundled_file_path, package_lock_path, ["baz"])
        end
      end

      context "when a config file of Licensed exists at the default path" do
        include_context "cd project root" do
          let(:ignored_package_names) { %w[test1 test2] }
          let(:licensed_config) { { "ignored" => { "npm" => ignored_package_names } } }
        end

        it "loads the package names ignored by Licensed from that file" do
          suppress_stdout { diff_command.run(argv) }
          expect(diff).to have_received(:compare_with_package_lock).with(bundled_file_path,
                                                                         package_lock_path,
                                                                         ignored_package_names)
        end
      end
    end

    shared_examples "help" do |argv|
      let(:expected_help_text) do
        <<~OUTPUT
          Usage: postlicensed diff <bundled-file> --license-checker [options]
                 postlicensed diff <bundled-file> --package-lock [path] [options]

          Options:
                  --license-checker
                  --licensed-config PATH
                  --package-lock [PATH]
        OUTPUT
      end

      it "prints help text and exits" do
        expect { diff_command.run(argv) }
          .to output(expected_help_text).to_stdout.and raise_error(SystemExit)
      end
    end

    context "when a bundled file path is not given" do
      it_behaves_like "help", ["diff"]
    end

    context "when no options are given" do
      it_behaves_like "help", ["diff", "path/to/bundled_file"]
    end

    context "when --help is given" do
      it_behaves_like "help", ["diff", "--help"]
    end
  end
end
