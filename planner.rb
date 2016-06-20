require 'time'

class Planner
  # Session length of Lighting sessions
  LIGHTNING_SESSION_LENGTH = 5
  # Minimum time of morning sessions
  MIN_MORNING_SESSIONS_TIME = 180
  # Class variable to store morning sessions
  @@morning_sessions = []
  # Class variable to store afternoon sessions
  @@afternoon_sessions = {}
  # Class variable to keep track of last track number
  @@track_no = 1

  # Method to store sessions
  def self.store_sessions sessions
    store_morning_sessions sessions
    plan_afternoon_sessions sessions
  end

  # Method to create plan sheet
  def self.create_plan_sheet sessions
    @@morning_sessions.each_with_index do |morning_session, session_index|
      write_plan_sheet morning_session, session_index, sessions
    end
  end

  # All private methods
  private
    # Method to plan afternoon sessions
    def self.plan_afternoon_sessions sessions
      @@morning_sessions.each_with_index do |session, session_index|
        remaining_sessions = (sessions - session)
        store_afternoon_sessions remaining_sessions, session_index
      end
    end

    # Method to store morning sessions
    def self.store_morning_sessions(sessions, partial_session = [])
      unless partial_session.empty?
        sessions_length_sum = sum_sessions_length partial_session
      end
      return @@morning_sessions.push(partial_session) if sessions_length_sum.eql?(MIN_MORNING_SESSIONS_TIME)
      (0..(sessions.length - 1)).each do |i|
        current_session = sessions[i]
        remaining_sessions = sessions.drop(i + 1)
        store_morning_sessions(remaining_sessions, partial_session + [current_session])
      end
    end

    # Method to sum of sessions length
    def self.sum_sessions_length partial_session
      sessions_length_sum =
        partial_session.collect do |session| 
          if session.session_length.downcase.eql? 'lightning'
            LIGHTNING_SESSION_LENGTH
          else
            session.session_length.to_i
          end
        end
      sessions_length_sum.inject 0, :+
    end

    # Method to store afternoon sessions
    def self.store_afternoon_sessions(sessions, session_index, partial_session = [])
      if partial_session.empty?
        sessions_length_sum = sum_sessions_length partial_session
      else
        sessions_length_sum = partial_session.collect{ |session| session.session_length.to_i }.inject 0, :+
      end
      if sessions_length_sum > (MIN_MORNING_SESSIONS_TIME)
        if @@afternoon_sessions[:"#{session_index}"].nil?
          @@afternoon_sessions[:"#{session_index}"] = []
          return @@afternoon_sessions[:"#{session_index}"].push(partial_session)
        else
          return @@afternoon_sessions[:"#{session_index}"].push(partial_session)
        end
      end
      (0..(sessions.length - 1)).each do |i|
        current_session = sessions[i]
        remaining_sessions = sessions.drop(i + 1)
        store_afternoon_sessions(remaining_sessions, session_index, partial_session + [current_session])
      end
    end

    # Method to write plan sheet
    def self.write_plan_sheet(morning_sessions, session_index, sessions)
      @@afternoon_sessions[:"#{session_index}"].each do |afternoon_session|
        add_tracks(morning_sessions, afternoon_session, sessions)
      end
    end

    # Method to add morning sessions in plan sheet
    def self.add_morning_sessions(morning_sessions, conference_time, file)
      morning_sessions.each_with_index do |morning_session, session_index|
        if(session_index.eql?(0))
          file.write("#{conference_time.strftime('%I:%M%p')} #{morning_session.session_name} #{morning_session.session_length}\n")
        else
          if morning_sessions[session_index - 1].session_length.eql? 'lightning'
            conference_time = (conference_time + (60 * LIGHTNING_SESSION_LENGTH))
          else
            conference_time = (conference_time + (60 * morning_sessions[session_index - 1].session_length.to_i))
          end
          file.write("#{conference_time.strftime('%I:%M%p')} #{morning_session.session_name} #{morning_session.session_length}\n")
        end
      end
    end

    # Method to add afternoon sessions in plan sheet
    def self.add_afternoon_sessions(afternoon_sessions, conference_time, file)
      afternoon_sessions.each_with_index do |afternoon_session, session_index|
        if(session_index.eql?(0))
          file.write("#{conference_time.strftime('%I:%M%p')} #{afternoon_session.session_name} #{afternoon_session.session_length}\n")
        else
          if afternoon_sessions[session_index - 1].session_length.eql? 'lightning'
            conference_time = (conference_time + (60 * LIGHTNING_SESSION_LENGTH))
          else
            conference_time = (conference_time + (60 * afternoon_sessions[session_index - 1].session_length.to_i))
          end
          file.write("#{conference_time.strftime('%I:%M%p')} #{afternoon_session.session_name} #{afternoon_session.session_length}\n")
        end
      end
    end

    # Method to add last hour(between 4PM to 5PM) sessions
    def self.add_last_hour_sessions(remaining_sessions, conference_time, file)
      last_session_length = 0
      remaining_sessions.each_with_index do |remaining_session, session_index|
        if remaining_sessions[session_index - 1].session_length.eql? 'lightning'
          conference_time = (conference_time + (60 * LIGHTNING_SESSION_LENGTH))
        else
          conference_time = (conference_time + (60 * remaining_sessions[session_index - 1].session_length.to_i))
        end
        last_session_length = remaining_session.session_length
        if (conference_time + (remaining_session.session_length.to_i * 60)) > Time.parse("05:00PM")
          conference_time = (conference_time - (60 * remaining_sessions[session_index - 1].session_length.to_i))
          break 
        end
        file.write("#{conference_time.strftime('%I:%M%p')} #{remaining_session.session_name} #{remaining_session.session_length}\n")
      end
      file.write("#{conference_time.strftime('%I:%M%p')} Networking Event\n")
    end

    # Method to add track in plan sheet
    def self.add_tracks(morning_sessions, afternoon_sessions, sessions)
      File.open('output/tracks.txt', 'a') do |file| 
        file.write "Track #{@@track_no}:\n"
        conference_time = Time.parse('9:00AM')
        add_morning_sessions(morning_sessions, conference_time, file)
        conference_time = Time.parse('12:00PM')
        file.write("#{conference_time.strftime('%I:%M%p')} Lunch\n")
        conference_time = Time.parse('1:00PM')
        add_afternoon_sessions(afternoon_sessions, conference_time, file)
        remaining_sessions = (sessions - (morning_sessions + afternoon_sessions))
        add_last_hour_sessions(remaining_sessions, conference_time, file)
        @@track_no += 1
      end
    end
end
