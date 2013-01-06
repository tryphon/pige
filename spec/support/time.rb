def time(string)
  # Time.parse changes day and month between 1.8 and 1.9
  Time.strptime string, "%m/%d/%Y %H:%M %Z"
end
