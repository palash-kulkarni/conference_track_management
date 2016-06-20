require_relative 'session'

class SessionList
  attr_reader :sessions

  # Method to create session_list
  def self.create sessions_detail
    session_list = []
    sessions_detail.each do |session_detail|
      session_list
        .push(Session.new(session_detail[:name],
                          session_detail[:length]))
    end
    session_list
  end
end
