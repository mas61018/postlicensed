# frozen_string_literal: true

require "json"

RSpec.describe Postlicensed::Diff do
  subject(:diff) { described_class.new }

  let(:bundled_file_path) { fixture_path("bundle-example.json") }

  describe "#compare_with_license_checker_result" do
    let(:license_checker_result) do
      JSON.pretty_generate(
        {
          "@scope/foo@1.0.0" => {
            "licenses" => "MIT"
          },
          "bar@2.0.0" => {
            "licenses" => "MIT"
          },
          "baz@3.0.0" => {
            "licenses" => "CC0-1.0"
          }
        }
      )
    end

    before do
      allow(diff).to receive(:execute_license_checker).and_return(license_checker_result)
    end

    it "returns the result of comparing the specified file with the output from license-checker" do
      expect(diff.compare_with_license_checker_result(bundled_file_path)).to eq <<~DIFF
        2a3
        > baz,3.0.0,cc0-1.0
      DIFF
    end

    context "when packages ignored by Licensed are given" do
      it "ignores the specified packages" do
        expect(diff.compare_with_license_checker_result(bundled_file_path, ["baz"])).to be_empty
      end
    end
  end

  describe "#compare_with_package_lock" do
    let(:package_lock_path) { fixture_path("package-lock.json") }

    it "returns the result of comparing the specified files" do
      expect(diff.compare_with_package_lock(bundled_file_path, package_lock_path)).to eq <<~DIFF
        2a3
        > baz,3.0.0
      DIFF
    end

    context "when packages ignored by Licensed are given" do
      it "ignores the specified packages" do
        expect(diff.compare_with_package_lock(bundled_file_path, package_lock_path, ["baz"])).to be_empty
      end
    end
  end
end
