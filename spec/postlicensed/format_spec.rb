# frozen_string_literal: true

require "fileutils"
require "tmpdir"

RSpec.describe Postlicensed::Format do
  subject(:format) { described_class.new }

  describe "#run" do
    let(:formatted_foo_yaml) do
      <<~YAML
        ---
        name: "@scope/foo"
        version: 1.0.0
        type: npm
        license: other
        licenses:
        - sources: LICENSE
          text: |
            Copyright (c) 2024 Example

            Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
        notices: []
      YAML
    end

    let(:formatted_bar_yaml) do
      <<~YAML
        ---
        name: bar
        version: 2.0.0
        type: npm
        license: other
        licenses:
        - sources: LICENSE
          text: |
            Copyright (c) 2024 Example

            Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
        notices: []
      YAML
    end

    it "returns Licensed caches with manual line breaks deleted" do
      licensed_cache_dir = fixture_path("licensed_caches/npm")
      expected_result = {
        File.join(licensed_cache_dir, "@scope/foo.dep.yml") => formatted_foo_yaml,
        File.join(licensed_cache_dir, "bar.dep.yml") => formatted_bar_yaml
      }
      expect(format.run(licensed_cache_dir)).to eq expected_result
    end

    context "when update == true" do
      let(:original_text) do
        <<~YAML
          - sources: LICENSE
            text: |
              Copyright (c) 2024 Example

              Permission to use, copy, modify, and/or distribute this software for any
              purpose with or without fee is hereby granted.
        YAML
      end

      it "updates Licensed caches" do
        Dir.mktmpdir do |tmpdir|
          FileUtils.cp_r(fixture_path("licensed_caches/npm"), tmpdir)
          licensed_cache_dir = File.join(tmpdir, "npm")
          read_foo = -> { File.read(File.join(licensed_cache_dir, "@scope/foo.dep.yml")) }
          read_bar = -> { File.read(File.join(licensed_cache_dir, "bar.dep.yml")) }
          expect { format.run(licensed_cache_dir, update: true) }
            .to change(&read_foo).from(include(original_text)).to(formatted_foo_yaml)
            .and change(&read_bar).from(include(original_text)).to(formatted_bar_yaml)
        end
      end
    end
  end
end
