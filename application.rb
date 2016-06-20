require_relative 'lib/parser'
require_relative 'session_list'
require_relative 'planner'
require 'yaml'

# Application class which have main control
class Application
  include Parser

  # Method to load config
  def load_config
    input_file_paths =
      YAML.load_file('config/input_file_paths.yml')
    input_file_paths['input_file_paths'].each do |_, input_file_path|
      start input_file_path
    end
  end

  private

    # Method from where actually execution starts
    def start(input_file_path)
      file_parser = FileParser.new input_file_path
      return puts 'File doesn\'t exist' unless file_parser.parse_and_store_matched_data
      sessions = 
        SessionList.create file_parser.matched_data
      Planner.store_sessions sessions
      Planner.create_plan_sheet sessions
    end
end

app = Application.new
app.load_config
