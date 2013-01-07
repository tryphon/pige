def time(string)
  # Time.parse changes day and month between 1.8 and 1.9
  if Time.respond_to? :strptime
    Time.strptime string, "%m/%d/%Y %H:%M %Z"
  else
    Time.parse string
  end
end
