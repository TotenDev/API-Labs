express = require("express")
http = require("http")
querystring = require('querystring')
app = express()
app.use express.static(__dirname + "/public")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router

app.get "/", (req, res) ->
    res.sendfile __dirname + "/index.html"

app.post "/request", (req, res) ->
    url = require('url').parse(req.body.url)
    requestData = querystring.stringify(req.body.parameters)
    options =
        host: url.host
        path: url.path
        method: req.body.method
        auth: req.body.auth
        headers:
            "Content-Type": "application/x-www-form-urlencoded"
            "Content-Length": requestData.length

    timerBegin = Date.now()
    request = http.request(options, (response) ->
        body = ''

        response.on "data", (chunk) ->
            body += chunk

        response.on "end", ->
            responseData =
                status: response.statusCode
                header: JSON.stringify(response.headers, null, 4)
                body: body
                time: (Date.now() - timerBegin) / 1000
            res.send(responseData)
    )

    request.on "error", (e) ->
        console.log "Error: " + e.message

    unless req.body.method is 'GET'
        request.write(requestData)

    request.end()

app.listen 8088