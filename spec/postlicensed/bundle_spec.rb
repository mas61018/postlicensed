# frozen_string_literal: true

require "json"
require "tmpdir"

RSpec.describe Postlicensed::Bundle do
  subject(:bundle) { described_class.new }

  describe "#run" do
    let(:bundled_json) do
      <<~JSON.chomp
        {
          "packages": [
            {
              "name": "@scope/foo",
              "version": "1.0.0",
              "license": {
                "type": "other",
                "digest": "63adb302d3003fcd3089c42f898d8f5d5b6e9ec3"
              }
            },
            {
              "name": "bar",
              "version": "2.0.0",
              "license": {
                "type": "other",
                "digest": "63adb302d3003fcd3089c42f898d8f5d5b6e9ec3"
              }
            }
          ],
          "licenseTexts": {
            "63adb302d3003fcd3089c42f898d8f5d5b6e9ec3": "Copyright (c) 2024 Example\\n\\nPermission to use, copy, modify, and/or distribute this software for any\\npurpose with or without fee is hereby granted.\\n"
          }
        }
      JSON
    end

    it "returns a bundled JSON" do
      expect(bundle.run(fixture_path("licensed_caches/npm"))).to eq bundled_json
    end

    it "sorts packages by name" do
      result = bundle.run(fixture_path("licensed_caches/sort_by_name"))
      expect(JSON.parse(result)["packages"]).to match [
        a_hash_including({ "name" => "example" }),
        a_hash_including({ "name" => "example-plugin" })
      ]
    end

    context "when package names are the same" do
      it "sorts packages by version" do
        result = bundle.run(fixture_path("licensed_caches/sort_by_version"))
        expect(JSON.parse(result)["packages"]).to match [
          a_hash_including({ "name" => "example", "version" => "9.0.0" }),
          a_hash_including({ "name" => "example", "version" => "10.0.0" })
        ]
      end
    end

    context "when output_file_path is given" do
      it "saves a bundled JSON file to the specified path" do
        Dir.mktmpdir do |tmpdir|
          output_file_path = File.join(tmpdir, "test.json")
          bundle.run(fixture_path("licensed_caches/npm"), output_file_path)
          expect(File.read(output_file_path)).to eq bundled_json
        end
      end
    end
  end
end
