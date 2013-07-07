class Event::TimeBased < AbstractEvent
  validates :trigger_time, presence: true
  validates :send_location, inclusion: {in: [true, false]}

  attr_accessor :repeats_on_week
  attr_accessible :repeats_on_week, :trigger_date, :trigger_time, :send_location, :repeats_on

  scope :with_location, where(send_location: true)
  scope :without_location, where(send_location: false)
  scope :repeating, where(repeats_on: nil)
  scope :non_repeating, where("events.repeats_on IS NOT NULL")

  before_validation :modify_repeates_on_weak

  def self.get_weekday_bit
    time = Time.now()
    time_beginning = time.beginning_of_day()
    minutes = (time.to_i - time_beginning.to_i)/60
    week_array = [0,0,0,0,0,0,0]
    week_array[time.wday] = 1

    return week_array.join("").to_i(base=2)
  end

  def self.events_to_trigger(options = {})
    location = options[:location]
    all_events = self.active

    if location
      all_events = all_events.with_location
      range = (minutes - 5)..(minutes + 5)
    else
      all_events = all_events.without_location
      range = (minutes - 5)..(minutes + 10)
    end

    all_events.where(trigger_time: range).where("
      (repeats_on IS NOT NULL AND (repeats_on & ? != 0)) 
      OR 
      (repeats_on IS NULL AND trigger_date = ?)", self.get_weekday_bit, Time.now().beginning_of_day())
  end

  private

  def modify_repeates_on_weak
    return if self.repeats_on_week.blank?

    array = self.repeats_on_week.split(",").collect(&:to_i)
    final_array = [0,0,0,0,0,0,0]

    final_array.each_with_index do |ele, i|
      final_array[i] = 1 if array.include?(i)
    end

    self.repeats_on = final_array.join("").to_i(base=2)
  end
end
