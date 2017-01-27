pg = require('pg')
say = require('say.js').dev
## Run a query
my_query = "select table_name from information_schema.tables where table_schema = 'public';"

host = process.argv[2]
say host

# create a config to configure both pooling behavior
# and client options
# note: all config is optional and the environment variables
# will be read if the config is not present
config = 
  database: process.env["DB"]
  user: process.env["USER"] 
  host: host
  port: 5432
  max: 10
  idleTimeoutMillis: 30000

pool = new (pg.Pool)(config) #Default pool w/ ten clients

# to run a query we can acquire a client from the pool,
# run a query on the client, and then return the client to the pool
pool.connect (err, client, done) ->
  if err
    return console.error('error fetching client from pool', err)
  query = client.query my_query, (err, result) ->
    #call `done()` to release the client back to the pool
    done()
    if err
      return console.error('error running query', err)
    console.log result.rows[0]
    #output: 1
    return
  query.on 'row', (row) ->
    table = row.table_name
    client.query "COPY "+ table.toString() + " TO '/tmp/"+table+".csv' DELIMITER ',' CSV HEADER;", (err, result) ->
      if err
        return console.error('error running query', err)
      say 'copied table', table 
      return
  pool.end()
  return
pool.on 'error', (err, client) ->
  # if an error is encountered by a client while it sits idle in the pool
  # the pool itself will emit an error event with both the error and
  # the client which emitted the original error
  # this is a rare occurrence but can happen if there is a network partition
  # between your application and the database, the database restarts, etc.
  # and so you might want to handle it and at least log it out
  console.error 'idle client error', err.message, err.stack
  return
