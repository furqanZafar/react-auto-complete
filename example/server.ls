require! \body-parser
require! \express
{each} = require \prelude-ls

app = express!
    ..set \views, __dirname + \/
    ..engine \.html, (require \ejs).__express
    ..set 'view engine', \ejs
    ..use (require \cookie-parser)!
    ..use body-parser.json!
    ..use body-parser.urlencoded {extended: false}

(require \./routes)
    |> each ([, method]:route) -> app[method].apply app, route.slice 2

port = 8000
app.listen port
console.log "listening on port: #{port}"