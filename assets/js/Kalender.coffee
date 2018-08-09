---
---

#Dieses Script parsed diesen Online-Kalender im iCal-Format: https://posteo.de/calendars/ics/s49fo2ntyyrp1pfk1u9vq1h34ho9j93v
#und fügt ihn in die Webseite ein.
#Nach diesem Tutorial: https://coffeescript-cookbook.github.io/chapters/ajax/ajax_request_without_jquery (Coffeescript Cookbook)

iCalURL = "https://posteo.de/calendars/ics/s49fo2ntyyrp1pfk1u9vq1h34ho9j93v"
xhr = new XMLHttpRequest()
calendarList = null;
calendarListItems = ''
dateOptions = {weekday: "short", month: "2-digit", day: "2-digit"}
hourOptions = {hour: "numeric", minute: "2-digit"}

URLREGEX = /(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?:\w+:\w+@)?((?:(?:[-\w\d{1-3}]+\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|edu|co\.uk|ac\.uk|it|fr|tv|museum|asia|local|travel|[a-z]{2}))|((\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)(\.(\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)){3}))(?::[\d]{1,5})?(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?:#(?:[-\w~!$ |\/.,*:;=]|%[a-f\d]{2})*)?/ig;               #Source: https://github.com/component/regexps/blob/master/index.js#L3
LINKTEXT = "Mehr Infos..."

urlify = (eventTitle, eventDesc) ->
  eventDesc = if eventDesc then eventDesc.replace(URLREGEX, "<a href=\"$&\" target=\"_blank\">$1</a>") else ''
  separator = if eventDesc then " +++ " else ''
  if eventTitle.includes("Bibelteilen") or eventTitle.includes("Jugendvigil")
    eventDesc = "<a href=\"{{ site.baseurl }}#{toLink(eventTitle)}\">#{LINKTEXT}</a>" + separator + eventDesc
  return eventDesc

toLink = (eventTitle) ->
  if eventTitle.includes("Bibelteilen") then return "{% link bibelteilen.md %}"
  if eventTitle.includes("Jugendvigil") then return "{% link jugendvigil.md %}"

stringifyDuration = (duration) ->
  if duration.compare(new ICAL.Duration({ hours: 1 })) < 0 then return "#{duration.minutes} Minuten" # less than an hour
  if duration.compare(new ICAL.Duration({ hours: 24 })) < 0 and duration.compare(new ICAL.Duration({ hours: 1 })) > -1 # between 1 and 24 hours
    return "#{(duration.hours+duration.minutes/60).toLocaleString('de')} Stunden"
  if duration.compare(new ICAL.Duration({ hours: 24 })) > -1 # greater or equal 24
    return "#{duration.days} Tag(e) #{duration.hours} Stunden"

xhr.addEventListener 'readystatechange', ->
  if xhr.readyState is 4                                    #ReadyState Complete
    successResultCodes = [200,304]
    document.getElementById('spinner').remove()
    if xhr.status in successResultCodes
      # Request iCal file
      response = xhr.responseText

      # Parse file
      icalExpander = new IcalExpander({ ics:response })

      # Evens between now and in 1 month
      nextMonth = new Date(Date.now())
      nextMonth.setMonth(nextMonth.getMonth()+1)
      events = icalExpander.between(new Date(Date.now()), nextMonth)

      # Get event details in human-readable Format
      mappedEvents = events.events.map((e) => ({
        startDate: e.startDate,
        endDate: e.endDate,
        summary: e.summary,
        description: e.description,
        location: e.location,
        duration: e.duration
      }))

      mappedOccurrences = events.occurrences.map((o) => ({
        startDate: o.startDate,
        endDate: o.endDate,
        summary: o.item.summary,
        description: o.item.description,
        location: o.item.location,
        duration: o.item.duration
      }))

      allEvents = [].concat(mappedEvents, mappedOccurrences)
      allEvents.sort((a, b) ->
        a.startDate.toJSDate() - b.startDate.toJSDate())

      for event in allEvents
        event.description = urlify(event.summary,event.description)
        event.location = "wird bekanntgegeben" unless event.location
        calendarListItems = calendarListItems + "<li><span class=\"date\">#{event.startDate.toJSDate().toLocaleString([], dateOptions)}</span> | #{event.summary}
                                                  <ul class=\"event-details\">
                                                    <li>Beginn: #{event.startDate.toJSDate().toLocaleString([], hourOptions)} (Dauer: #{stringifyDuration(event.duration)})</li>
                                                    <li>Ort: #{event.location}</li>"
        if event.description
          calendarListItems = calendarListItems +  "<li class=\"event-description\">#{event.description}</li>
                                                  </ul>
                                                </li>"
        else
          calendarListItems = calendarListItems + "</ul>
                                                </li>"

      if calendarListItems
        calendarList.innerHTML = '<p>Die Termine im nächsten Monat:</p><ul>' + calendarListItems + '</ul>'
      else
        calendarList.innerHTML = 'Im nächsten Monat sind keine Veranstaltungen geplant.'
    else
      calendarList.innerHTML = 'Fehler beim Laden der Kalenderdaten. Probiere es später noch einmal oder kontaktiere uns (siehe unten).'

xhr.open 'GET', 'https://cors-anywhere.herokuapp.com/' + iCalURL

window.onload = ->
  calendarList = document.getElementById 'calendar'                               #<div> mit entsprechender Id suchen
  xhr.send()
