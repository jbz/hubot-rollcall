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
    msg.send "I see the following attendees:"
    for attendee in attendees
      msg.send "#{attendee}"

    # Store new rollcall in brain
    robot.brain.data.rollcall or= {}
    robot.brain.data.rollcall[room] = {
      start: new Date().getTime(),
      attendees: attendees,
      remaining: attendees,
      log: [],
    }
