---
---

#Dieses Script parsed diesen Online-Kalender im Atom/XML-Format: https://posteo.de/calendars/feed/s49fo2ntyyrp1pfk1u9vq1h34ho9j93v
#und fügt ihn in die Webseite ein.
#Nach diesem Tutorial: https://coffeescript-cookbook.github.io/chapters/ajax/ajax_request_without_jquery (Coffeescript Cookbook)

xhr = new XMLHttpRequest()
calendarList = null;
URLREGEX = /(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?:\w+:\w+@)?((?:(?:[-\w\d{1-3}]+\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|edu|co\.uk|ac\.uk|it|fr|tv|museum|asia|local|travel|[a-z]{2}))|((\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)(\.(\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)){3}))(?::[\d]{1,5})?(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?:#(?:[-\w~!$ |\/.,*:;=]|%[a-f\d]{2})*)?/ig;               #Source: https://github.com/component/regexps/blob/master/index.js#L3
LINKTEXT = "Mehr Infos..."

urlify = (eventTitle, eventDesc) ->
  eventDesc = eventDesc.replace(URLREGEX, "<a href=\"$&\" target=\"_blank\">$1</a>")
  separator = if eventDesc then " +++ " else ''
  if ["Bibelteilen","Jugendvigil"].includes(eventTitle) then eventDesc = "<a href=\"{{ site.baseurl }}#{toLink(eventTitle)}\">#{LINKTEXT}</a>" + separator + eventDesc
  eventDesc

toLink = (eventTitle) ->
  switch eventTitle
    when "Bibelteilen" then return "{% link bibelteilen.md %}"
    when "Jugendvigil" then return "{% link jugendvigil.md %}"


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
      calendarListItems = ''
      dateOptions = {weekday: "short", month: "2-digit", day: "2-digit"}
      hourOptions = {hour: "numeric", minute: "2-digit"}
      for event in events
        calendarListItems = calendarListItems + "<li><span class=\"date\">#{event.date.toLocaleString([], dateOptions)}</span> | #{event.title}
                                                  <ul class=\"event-details\">
                                                    <li>Beginn: #{event.date.toLocaleString([], hourOptions)}</li>
                                                    <li>Ort: #{event.venue}</li>
                                                    <li class=\"event-description\">#{urlify(event.title,event.description)}</li>
                                                  </ul>
                                                </li>"
      if calendarListItems
        calendarList.innerHTML = '<p>Die Termine im nächsten Monat:</p><ul>' + calendarListItems + '</ul>'
      else
        calendarList.innerHTML = 'Im nächsten Monat sind keine Veranstaltungen geplant.'
    else
      calendarList.innerHTML = 'Fehler beim Laden der Kalenderdaten. Probiere es später noch einmal oder kontaktiere uns (siehe unten).'

xhr.open 'GET', 'https://cors-anywhere.herokuapp.com/https://posteo.de/calendars/feed/s49fo2ntyyrp1pfk1u9vq1h34ho9j93v'

window.onload = ->
  calendarList = document.getElementById 'calendar'                               #<div> mit entsprechender Id suchen
  xhr.send()
