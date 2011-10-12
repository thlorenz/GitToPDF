socket = io.connect('http://localhost')

prompt = "<span class='terminal_prompt'>supergit@gittopdfifier.com $ </span>"
success = "<span class='terminal_success'> Ok</span>"
failure = "<span class='terminal_failure'> Not Ok</span>"
linefeed = "<br/>"

appendLinefeed = -> $("#terminal").append linefeed
appendPrompt = -> $("#terminal").append prompt
appendSuccess = -> $("#terminal").append success
appendFailure = -> $("#terminal").append failure
appendAction = (message) ->
  action = "<span class='terminal_action'>#{message}</span>"
  $("#terminal").append action

socket.on 'action', (data) ->
  appendLinefeed()
  appendPrompt()
  appendAction data.message

socket.on 'success',(data) ->
  appendSuccess()
  $("#progressBar").attr "value", data.percent


socket.on 'failure', appendFailure

socket.on 'connect', ->
  convertButton = $("#convertButton")
  convertInput = $("#convertInput")
  convertInput.attr("value", "https://github.com/LearnBoost/socket.io.git")

  requestConversion = ->
    url = convertInput.attr("value")
    console.log "Requesting to convert:",url
    socket.emit 'convert', { url }

  convertButton.click(requestConversion)
