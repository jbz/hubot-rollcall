# hubot-rollcall

Attendance taking functionality for [hubot](https://github.com/github/hubot).
Coffeescript and hubot teachings gratefully taken from [hubot-standup](https://github.com/miyagawa/hubot-standup), amongst other places.

## How to use

Create a room (or channel on IRC) for rollcall and invite hubot to the room if necessary.

### Start the rollcall

You start the rollcall by telling hubot to start one and giving it a list of users who
you would like to confirm are present. Usernames must begin with a '@' or rollcall will
ignore them. Rollcall will also deduplicate the username list.

```
jbz: hubot rollcall start @jbz @ianw @zach @jbz
hubot: Starting a rollcall for the following attendees: @jbz @ianw @zach
```

### Confirming your presence

Tell the robot you're here.

```
jbz: hubot here
hubot: @jbz is here! (1/3) are here!
```

### Stand-ins

You can stand in for an attendee by saying 'sub for <user>' or 'stand-in for <user>'.

```
lolo: hubot sub for @zach
hubot: @lolo is standing in for @zach! (2/3) are here! 
```

### Checking on status

At any time, you can ask hubot who has not yet checked in.

```
jbz: hubot rollcall status
hubot: Rollcall in progress.  Waiting for 1 of 3 participants - @ianw
```

### Completion

When the last person (or stand-in) checks in, the rollcall will be announced complete.

```
ianw:  hubot present
hubot: @ianw is here!  Attendance check COMPLETED at 07.27 14:17
```

### Canceling the rollcall

Each channel/room can only have one rollcall ongoing at a time.  If you try to start
another before completing/canceling the first, you'll get an error message:

```
ianw: hubot rollcall start @jbz @zach
hubot: There is already a rollcall in progress here!  Cancel it first with 'hubot rollcall cancel'
```
 
## Author

[J.B. Zimmerman](https://github.com/jbz)

## License

MIT License
