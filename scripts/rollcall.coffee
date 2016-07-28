# Description:
#   Slack rollcall bot
#
# Commands:
#   hubot rollcall? - show help for the rollcall
#   hubot rollcall <user1> <user2> ... <userN> - start a rollcall of the named users
#   hubot cancel rollcall - cancel the current rollcall
#   hubot skip <user> - skip someone when they're not available
#
# Author:
#   @jbz

module.exports = (robot) ->
  robot.respond /rollcall (?:cancel|stop) *$/i, (msg) ->
    delete robot.brain.data.rollcall?[msg.message.user.room]
    msg.send "Rollcall cancelled"

  robot.respond /rollcall\?? *$/i, (msg) ->
    msg.send """
             #{robot.name} rollcall start <user1> ... <userN> - start a rollcall for the listed users
             #{robot.name} rollcall cancel - cancel the current rollcall 
             #{robot.name} rollcall status - see who we're still waiting for
             #{robot.name} here|present|raised_hand - indicate you are present for the rollcall
             #{robot.name} sub|substitute|stand-in for <user> - indicate you are subbing for <user>
             """
  robot.respond /debug/, (msg) ->
    console.log Object(msg)

  robot.respond /rollcall start (.*?) *$/i, (msg) ->
    room = msg.message.room
    if robot.brain.data.rollcall?[room]
      msg.send "There is already a rollcall in progress here! Cancel it first with '#{robot.name} rollcall cancel'"
      return

    # Get list of actual usernames in rollcall list
    attendees = (msg.match[1].split " ").filter (x) -> x.charAt(0) == "@" 
    attendees = attendees.unique()
    msg.send "Starting a rollcall at #{formatDate(new Date())} for the following attendees: #{attendees.join(" ")}"

    # Store new rollcall in brain
    robot.brain.data.rollcall or= {}
    robot.brain.data.rollcall[room] = {
      start: new Date(),
      attendees: attendees,
      remaining: attendees,
    }

  robot.respond /(?:\bhere\b|\bpresent\b|:raised_hand:)/, (msg) ->
    room = msg.message.room
    if robot.brain.data.rollcall?[room] and not robot.brain.data.rollcall[room].finish?
      rollcall = robot.brain.data.rollcall[room]
      roster = rollcall.remaining
      if ("@" + msg.message.user.name) in rollcall.remaining
        msg.send "@#{msg.message.user.name} is here!"
        newAttendees = roster.filter (e) -> e != ("@" + msg.message.user.name)
        if newAttendees.length == 0
          completeRollcall(msg)
          return
        robot.brain.data.rollcall[room].remaining = newAttendees
        msg.send "(#{newAttendees.length}/#{rollcall.attendees.length}) are here!"
      else
        msg.send "You're not in the rollcall."
    else
      msg.send "No rollcall in progress."

  robot.respond /(?:\bsub\b|\bsubstitute\b|\bstandin\b|stand-in\b) for (\@.*?) *$/i, (msg) ->
    room = msg.message.room
    absent = msg.match[1]
    if robot.brain.data.rollcall?[room] and not robot.brain.data.rollcall[room].finish?
      rollcall = robot.brain.data.rollcall[room]
      roster = rollcall.remaining
      if absent in rollcall.remaining
        msg.send "@#{msg.message.user.name} is standing in for #{absent}!"
        newAttendees = roster.filter (e) -> e != absent
        if newAttendees.length == 0
          completeRollcall(msg)
          return
        robot.brain.data.rollcall[room].remaining = newAttendees
      else
        msg.send "We're not waiting for that person!"
    else
      msg.send "No rollcall in progress."

  robot.respond /rollcall status/i, (msg) ->
    msg.send "Status command"
    room = msg.message.room
    if robot.brain.data.rollcall?[room]
      msg.send "Rollcall in progress.  Waiting for #{robot.brain.data.rollcall[room].remaining.length} of #{robot.brain.data.rollcall[room].attendees.length} paticipants - #{robot.brain.data.rollcall[room].remaining.join(' ')}"
    else
      msg.send "No rollcall in progress!  Start one with '#{robot.name} rollcall start @user1 ... @userN'"

formatDate = (date) ->
  timeStamp = [(date.getMonth() + 1), date.getDate()].join("/") + " " + [date.getHours(), date.getMinutes()].join(":")
  RE_findSingleDigits = /\b(\d)\b/g

  # Places a `0` in front of single digit numbers.
  timeStamp = timeStamp.replace( RE_findSingleDigits, "0$1" )
  timeStamp.replace /\s/g, ""
  return timeStamp

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

completeRollcall = (msg) ->
  room = msg.message.room
  # robot.brain.data.rollcall[room].finish = new Date()
  delete robot.brain.data.rollcall[room]
  msg.send "Rollcall COMPLETED at #{formatDate(new Date())}"
