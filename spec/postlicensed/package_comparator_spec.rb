# frozen_string_literal: true

RSpec.describe Postlicensed::PackageComparator do
  subject(:comparator) { described_class.new }

  describe "#compare_packages" do
    it "compares package names" do
      example = { "name" => "example", "version" => "1.0.0" }
      example_plugin = { "name" => "example-plugin", "version" => "1.0.0" }
      aggregate_failures do
        expect(comparator.compare_packages(example, example_plugin)).to be < 0
        expect(comparator.compare_packages(example_plugin, example)).to be > 0
        expect(comparator.compare_packages(example, example)).to eq 0
      end
    end

    context "when package names are the same" do
      it "compares package versions" do
        v9 = { "name" => "example", "version" => "9.0.0" }
        v10 = { "name" => "example", "version" => "10.0.0" }
        aggregate_failures do
          expect(comparator.compare_packages(v9, v10)).to be < 0
          expect(comparator.compare_packages(v10, v9)).to be > 0
          expect(comparator.compare_packages(v9, v9)).to eq 0
        end
      end
    end
  end

  describe "#to_proc" do
    it "returns a proc that compares packages" do
      package1 = { "name" => "package1", "version" => "1.0.0" }
      package2 = { "name" => "package2", "version" => "1.0.0" }
      expect(comparator.to_proc.call(package1, package2)).to be < 0
    end
  end
end
