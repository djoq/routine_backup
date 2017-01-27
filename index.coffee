exec = require('child_process').exec
say = require('say.js').dev

cmd = "docker inspect postgres"

eventually = (host) ->
  say "docker host ->", host
  cmd = "docker cp postgres:/tmp/ dumps/"
  exec(cmd, (error, stdout, stderr) ->
    say stdout
    if error != null
      say 'exec error: ' + error
    return
  )

initial = (cmd) ->
  exec(cmd, (error, stdout, stderr) ->
    #res = JSON.parse JSON.stringify stdout
    res = JSON.parse stdout

    pg_ip = res[0].NetworkSettings.IPAddress
    say 'initailly: ' + pg_ip

    exec("coffee drink.coffee "+pg_ip, (error, stdout, stderr) ->
      say stdout
      eventually ip: pg_ip
      if error != null
        say 'exec error: ' + error
      return
    )

    if error != null
      say 'exec error: ' + error
    return
  )
initial cmd
