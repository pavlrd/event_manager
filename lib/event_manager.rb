require "csv"
require "sunlight/congress"
require "erb"
require "date"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
	Dir.mkdir("/Users/maxvrednov/desktop/projects/event_manager/output") unless Dir.exists? "/Users/maxvrednov/desktop/projects/event_manager/output"

    filename = "/Users/maxvrednov/desktop/projects/event_manager/output/thanks_#{id}.html"

    File.open(filename, "w") do |file|
    	file.puts form_letter
	end
end

def clean_phone(phone_number)                  #My solution for clean phone numbers problem in eventmanager
	number = phone_number.scan(/\d+/).join
	ph = number.length
	if ph<10 || ph == 11 && number[0] != 1 || ph > 11
		"bad number"
	elsif ph == 10
		number
	elsif ph == 11 && number[0] == 1
		number = number[0..-1]
	end
end

def hour(date_time)
	DateTime.strptime(date_time, "%m/%d/%y %H:%M")
end

hours = []

def peak_hours(hours)                         #My solution how to find peak registration hours in eventmanager
	hours_count = {}
	hours.each do |hour|
		if hours_count.has_key?(hour)
			hours_count[hour] += 1
		else
			hours_count[hour] = 1
		end
	end
	hours_count.each do |hour, count|          #I assume that hour is peak when were registered more than 2 people in that hour
		if count > 2
			puts hour
		end
	end
end

days = []

def peak_days(days)                           #My solution how to find peak registration days in eventmanager
	days_count = {}
	days.each do |day|
		if days_count.has_key?(day)
			days_count[day] += 1
	    else
			days_count[day] = 1
		end
	end
	days_count.each do |day, count|
		if count > 2                          #Same as with peak hour I assume that day is peak when were registered more than 2 people in one day
			puts Date::DAYNAMES[day]
		end
	end
end 


puts "EventManager Initialized!"


contents = CSV.open "/Users/maxvrednov/desktop/projects/event_manager/event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "/Users/maxvrednov/desktop/projects/event_manager/form_letter.erb"
erb_template = ERB.new template_letter



contents.each do |row|
	id = row[0]
	name = row[:first_name]

	hours << hour(row[:regdate]).hour

    days << hour(row[:regdate]).wday

	zipcode = clean_zipcode(row[:zipcode])

	phone_number = clean_phone(row[:homephone])

	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)

    save_thank_you_letters(id, form_letter)
end
