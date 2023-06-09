**Details:**
- Simple weather app with weather API from openweathermap.org
- Used MVVM architecture with a network layer, location manager and Data cache.
- Loads current weather if location is allowed, else you can search a city and select the right option from the list of places to see its weather details.

https://user-images.githubusercontent.com/8175781/225207644-acabb045-4492-446b-a58e-4828d2f24df4.mp4


**Known issues:**
- UI improvements: Need to iron out layout spacing issues that show up in landscape mode
- Activity indicator wont stop if the user has denied location access and has no previous location saved. (used a hack for now)

**Future improvements:**
- Find a better way to store the API key in the code
- Better error handling: May be have custom error codes and inform the views of the error to be handled as needed.
- refactor code to avoid duplication
- placeholder image for the icon while its loading
