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
  robot.respond /(?:cancel|stop) rollcall *$/i, (msg) ->
    delete robot.brain.data.rollcall?[msg.message.user.room]
    msg.send "Rollcall cancelled"

  robot.respond /rollcall\?? *$/i, (msg) ->
    msg.send """
             rollcall <user1> ... <userN> - start a rollcall for the listed users
             cancel rollcall - cancel the current rollcall 
             skip <user> - skip someone because they're not available or are unnecessary
             """
  robot.respond /debug/, (msg) ->
    console.log Object(msg)

  robot.respond /start rollcall (.*?) *$/i, (msg) ->
    room  = msg.message.user.room
    if robot.brain.data.rollcall?[room]
      msg.send "There is already a rollcall in progress in #{robot.brain.data.rollcall[room]}! Cancel it first with 'cancel rollcall'"

    # Get list of actual usernames in rollcall list
    attendees = (msg.match[1].split " ").filter (x) -> x.charAt(0) == "@" 
    attendees = attendees.unique()
    msg.send "I see the following attendees:"
    for attendee in attendees
      msg.send "#{attendee}"

    # Store new rollcall in brain
    robot.brain.data.rollcall or= {}
    robot.brain.data.rollcall[room] = {
      start: new Date(),
      attendees: attendees,
      remaining: attendees,
      log: [],
    }

  robot.respond /(?:\bhere\b|\bpresent\b)/i, (msg) ->
    room = msg.message.user.room
    msg.send "Saw a hand raised!"
    if robot.brain.data.rollcall?[room]
      rollcall = robot.brain.data.rollcall[room]
      roster = rollcall.remaining
      if ("@" + msg.message.user.name) in rollcall.remaining
        msg.send "#{msg.message.user.name} is here!"
        msg.send "Removing from rollcall..."
        newAttendees = roster.filter (e) -> e != ("@" + msg.message.user.name)
        if newAttendees.length == 0
          msg.send "EMPTY ROLLCALL!"
          robot.brain.data.rollcall[room].finish = new Date()
          msg.send "Finish time is #{formatDate(robot.brain.data.rollcall[room].finish)}"
        robot.brain.data.rollcall[room].remaining = newAttendees
      else
        msg.send "Don't know you." # Eventually, ignore

  robot.respond /(?:\bsub\b|\bsubstitute\b|\bhere\b) for (\@.*?) *$/i, (msg) ->
    room = msg.message.user.room
    sub = msg.match[1]
    msg.send "#{sub}"
    msg.send "Saw a substitute volunteer!"
    if robot.brain.data.rollcall?[room]
      rollcall = robot.brain.data.rollcall[room]
      roster = rollcall.remaining
      if sub in rollcall.remaining
        msg.send "#{msg.message.user.name} is standing in for #{sub}!"
        newAttendees = roster.filter (e) -> e != sub
        if newAttendees.length == 0
          msg.send "ROLLCALL COMPLETE!"
          robot.brain.data.rollcall[room].finish = new Date()
          msg.send "Finish time is #{formatDate(robot.brain.data.rollcall[room].finish)}"
        robot.brain.data.rollcall[room].remaining = newAttendees
      else
        msg.send "Don't know you." # Eventually, ignore

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
