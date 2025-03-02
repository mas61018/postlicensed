# frozen_string_literal: true

module Postlicensed
  class PackageComparator
    # @rbs!
    #   type package = { "name" => String, "version" => String }

    #: (package, package) -> Integer
    def compare_packages(package1, package2)
      value = package1["name"] <=> package2["name"]
      return value if value != 0

      version1 = Gem::Version.new(package1["version"])
      version2 = Gem::Version.new(package2["version"])
      (version1 <=> version2) || 0
    end

    def to_proc
      method(:compare_packages).to_proc
    end
  end
end
