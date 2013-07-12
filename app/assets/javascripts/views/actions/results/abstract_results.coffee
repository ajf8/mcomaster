###
 Copyright 2013 ajf http://github.com/ajf8

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
###
MCM.Views.AbstractActionResults = Backbone.Marionette.CompositeView.extend({
  events: {
    "click a.export-csv" : "exportCSV"
    "click a.export-json" : "exportJSON"
  }

  # Create a fake link with a data: URL. the download attribute sets the filename
  # (this can't be done with window.open AFAIK) then synthesise a click event
  localDownload: (type, name, content) ->
    link = document.createElement("a")
    link.setAttribute("href", 'data:'+type+';charset=utf-8,'+encodeURIComponent(content))
    link.setAttribute("download", name)
    theEvent = document.createEvent("MouseEvent")
    theEvent.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
    link.dispatchEvent(theEvent)
    
  csvEscape: (text) ->
    if text == undefined or text == ""
      return ""
    else if typeof(text) != "string"
      text = text.toString()
    
    needsQuotes = false
    
    if text.indexOf('"') >= 0
      text = text.replace('"', '""')
      needsQuotes = true

    if text.indexOf("\n") >= 0
      text = text.replace("\n", '\\n')
      needsQuotes = true

    if text.indexOf("\r") >= 0
      text = text.replace("\r", '\\n')
      needsQuotes = true
      
    if text.indexOf(",") >= 0
      needsQuotes = true
        
    if needsQuotes
      return '"'+text+'"'
    else
      return text
  
  exportJSON: (e) ->
    name = @options.agent+"-"+@options.action+"-"+moment().format("YYYYMMDD_HHmm")+".json"
    @localDownload "text/csv", name, JSON.stringify(@collection.toJSON())
    e.preventDefault()
    
  exportCSV: (e) ->
    csv = ''
    csv_row = ['Node','Status']
    
    for col in @options.ddl.columns
      csv_row.push(@csvEscape(col.display_as))
    
    csv += csv_row.join(",")+'\r\n'
      
    for model in @collection.models
      csv_row = [model.attributes.senderid, model.attributes.body.statusmsg]
      for col in @options.ddl.columns
        csv_row.push(@csvEscape(model.attributes.body.data[col.key]))
      csv += csv_row.join(",")+'\r\n'
    
    name = @options.agent+"-"+@options.action+"-"+moment().format("YYYYMMDD_HHmm")+".csv"
    @localDownload "text/csv", name, csv
    
    e.preventDefault()
    
  setError: (error) ->
    @error = error
    @render()
})
