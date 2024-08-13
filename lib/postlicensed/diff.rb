# frozen_string_literal: true

require "csv"
require "json"
require "shellwords"
require "tempfile"
require_relative "package_comparator"

module Postlicensed
  class Diff
    def compare_with_license_checker_result(bundled_file_path, licensed_ignore = [])
      main_data = format_bundled_file(bundled_file_path, include_license: true)
      license_checker_result = format_license_checker_result(licensed_ignore)
      diff(main_data, license_checker_result)
    end

    def compare_with_package_lock(bundled_file_path, package_lock_path, licensed_ignore = [])
      main_data = format_bundled_file(bundled_file_path)
      package_lock = format_package_lock(package_lock_path, licensed_ignore)
      diff(main_data, package_lock)
    end

    private

    def generate_csv(packages)
      CSV.generate do |csv|
        packages.each { |hash| csv << hash.values }
      end
    end

    def format_bundled_file(bundled_file_path, include_license: false)
      packages = JSON.parse(File.read(bundled_file_path))["packages"].map do |package|
        data = package.slice("name", "version")
        data["license"] = package["license"]["type"] if include_license
        data
      end
      generate_csv(packages)
    end

    def execute_license_checker
      IO.pipe do |read_io, write_io|
        system("npx --no -- license-checker --excludePrivatePackages --json --production",
               exception: true, out: write_io)
        write_io.close
        read_io.read
      end
    end

    def format_license_checker_result(licensed_ignore)
      packages = JSON.parse(execute_license_checker).filter_map do |key, value|
        name, _, version = key.rpartition("@")
        next false if licensed_ignore.include?(name)

        { name:, version:, license: value["licenses"].downcase }.transform_keys(&:to_s)
      end
      generate_csv(packages.sort(&PackageComparator.new))
    end

    def format_package_lock(package_lock_path, licensed_ignore)
      packages = JSON.parse(File.read(package_lock_path))["packages"].filter_map do |key, value|
        name = key.sub(%r{.*(/|^)node_modules/}, "")
        next false if name.empty? || licensed_ignore.include?(name) || value["dev"]

        { name:, version: value["version"] }.transform_keys(&:to_s)
      end
      generate_csv(packages.sort(&PackageComparator.new))
    end

    def diff(string1, string2)
      path1, path2 = [string1, string2].map do |string|
        Tempfile.open do |tempfile|
          tempfile.write(string)
          tempfile.path
        end
      end
      `diff #{path1.shellescape} #{path2.shellescape}`
    end
  end
end
