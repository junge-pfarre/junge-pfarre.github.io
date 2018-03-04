---
---

#Dieses Script parsed diesen Online-Kalender im Atom/XML-Format: https://posteo.de/calendars/feed/s49fo2ntyyrp1pfk1u9vq1h34ho9j93v
#und fügt es in die Webseite ein.
#Nach diesem Tutorial: https://coffeescript-cookbook.github.io/chapters/ajax/ajax_request_without_jquery (Coffeescript Cookbook)

xhr = new XMLHttpRequest()

xhr.addEventListener 'readystatechange', ->
  if xhr.readyState is 4                                                        #ReadyState Complete
    successResultCodes = [200,304]
    document.getElementById('spinner').remove()
    if xhr.status in successResultCodes
      response = xhr.responseXML
      resolver = -> 'http://www.w3.org/2005/Atom'                               #Atom namespace resolver
      calendarTitles = response.evaluate '/Atom:feed/Atom:entry/Atom:title', response, resolver, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null
      calendarDates = response.evaluate '/Atom:feed/Atom:entry/Atom:updated', response, resolver, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null
      calendarContent = response.evaluate '/Atom:feed/Atom:entry/Atom:content', response, resolver, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null
      snapshotMaxIndex = calendarTitles.snapshotLength-1
      x = [0..snapshotMaxIndex]
      events = ({title: calendarTitles.snapshotItem(i).innerHTML, date: new Date(calendarDates.snapshotItem(i).innerHTML), venue: calendarContent.snapshotItem(i).innerHTML.split('$')[0], description: calendarContent.snapshotItem(i).innerHTML.split('$')[1]} for i in x)        #parse all entries to json
      testtime = new Date(Date.now())
      testtime.setHours(testtime.getHours() - 11)
      events = (event for event in events when event.date > testtime)           #Vergangene Events werden nach 12 Stunden (11h in MESZ) aussortiert
      events.reverse()                                                          #Umordnen, da Originaldaten absteigend geordnet sind
      calendarList = document.getElementById 'calendar'                         #<div> mit entsprechender Id suchen
      calendarListItems = ''
      dateOptions = {weekday: "short", month: "2-digit", day: "2-digit"}
      hourOptions = {hour: "numeric", minute: "2-digit"}
      for event in events
        calendarListItems = calendarListItems + "<li><span class=\"date\">#{event.date.toLocaleString([], dateOptions)}</span> | #{event.title}
                                                  <ul class=\"event-details\">
                                                    <li>Beginn: #{event.date.toLocaleString([], hourOptions)}</li>
                                                    <li>Ort: #{event.venue}</li>
                                                    <li class=\"event-description\">#{event.description}</li>
                                                  </ul>
                                                </li>"
      if calendarListItems
        calendarList.innerHTML = '<p>Die Termine im nächsten Monat:</p><ul>' + calendarListItems + '</ul>'
      else
        calendarList.innerHTML = 'Im nächsten Monat sind keine Veranstaltungen geplant.'
    else
      calendarList.innerHTML = 'Fehler beim Laden der Kalenderdaten.'

xhr.open 'GET', 'https://cors-anywhere.herokuapp.com/https://posteo.de/calendars/feed/s49fo2ntyyrp1pfk1u9vq1h34ho9j93v'
xhr.send()
