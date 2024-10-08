# frozen_string_literal: true

module StringExtension
  refine String do
    def blank?
      strip.empty?
    end
  end
end

using StringExtension

module Postlicensed
  class Format
    class LicenseTextFormatter
      def format(text)
        text = clean_whitespace(text)
        text.lines("")
            .map { |paragraph| delete_manual_line_breaks(paragraph) }
            .join
      end

      DENSITY_THRESHOLD = 0.9

      PRINT_WIDTH = 80

      private_constant :DENSITY_THRESHOLD,
                       :PRINT_WIDTH

      private

      def clean_whitespace(text)
        text.gsub(/(^|(?<=\S))\s*?(\R)/, "\\2")
            .lines
            .drop_while(&:blank?)
            .reverse.drop_while(&:blank?).reverse
            .join
      end

      def copyright?(line)
        /Copyright (©|\(c\)|\d{4})/i.match?(line) || /All rights reserved/i.match?(line)
      end

      def heading?(line)
        /^\s*# /.match?(line)
      end

      def quote?(line)
        /^\s*> /.match?(line)
      end

      def preserve?(line)
        copyright?(line) || heading?(line) || quote?(line)
      end

      def list_item?(line)
        /^\s*(-|\*|\d\.) /.match?(line)
      end

      def sentence?(lines)
        return true if lines.any? { |line| /(\."?|:|;( and)?)\s*$/.match?(line) }

        _last_line, *rest = lines.reverse.map(&:rstrip).reject(&:empty?)
        density = rest.map(&:length).sum.to_f / (PRINT_WIDTH * rest.size)
        density > DENSITY_THRESHOLD
      end

      def concat(lines)
        lines.reduce do |result, line|
          if line.blank?
            result + line
          else
            "#{result.rstrip} #{line.lstrip}"
          end
        end
      end

      def delete_manual_line_breaks(paragraph)
        chunk_value = 0

        chunks = paragraph.lines.chunk do |line|
          next :_alone if preserve?(line)

          chunk_value += 1 if list_item?(line)
          chunk_value
        end

        chunks.map { |key, lines| key != :_alone && sentence?(lines) ? concat(lines) : lines }
              .flatten.join
      end
    end
  end
end
