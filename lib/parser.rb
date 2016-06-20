require_relative '../session'

module Parser
  # Class which reads input file and parses line by line
  class FileParser
    attr_reader :matched_data

    # Constructor
    def initialize file_path
      @file_path = file_path
      @rule = /\blightning\b|\b\d*min\b/
      @matched_data = []
    end

    # parse input file and stores session name along with session length
    def parse_and_store_matched_data
      return false unless File.exists?(@file_path)
      File.open(@file_path, 'r').readlines.each do |line|
        next if line.strip.length.eql?(0)
        @matched_data.push scan(line)
      end
      true
    end

    private 

      # scans each line of input file
      def scan line
        matched_data = @rule.match(line)
        return fail 'Input format is invalid' unless matched_data
        matched_string = matched_data.to_a.first
        splitted_line_part =
          line.split(matched_string).first.strip
        { name: splitted_line_part, 
          length: matched_string }
      end
  end
end
