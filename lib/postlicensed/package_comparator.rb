# frozen_string_literal: true

module Postlicensed
  class PackageComparator
    def compare_packages(package1, package2)
      value = package1["name"] <=> package2["name"]
      return value if value != 0

      version1, version2 = [package1, package2].map { Gem::Version.new(_1["version"]) }
      version1 <=> version2
    end

    def to_proc
      method(:compare_packages).to_proc
    end
  end
end
