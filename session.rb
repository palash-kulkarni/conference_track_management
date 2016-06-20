class Session
  attr_reader :session_name, :session_length
  
  def initialize(session_name = '', session_length = '')
    @session_name = session_name
    @session_length = session_length
  end
end
