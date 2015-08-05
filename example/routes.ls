{promises: {bindP, from-error-value-callback, returnP, to-callback}} = require \async-ls
require! \express
{read-file} = require \fs
{any, filter, map, take} = require \prelude-ls

# :: a -> [ExpressRoute]
module.exports = do ->

    # die :: Response -> Error -> Void
    die = (res, err) !->
        console.log err.to-string!
        res.status 500 .end err.to-string!

    scripts = null

    pretty = -> JSON.stringify it, null, 4

    return
        * \node_modules, \use, \/node_modules, express.static "#__dirname/node_modules"
        * \public, \use, \/public, express.static "#__dirname/public"
        * \data, \use, \/data, express.static "#__dirname/data"
        * \index, \get, \/, (req, res) -> res.render \public/index.html
        * \scripts, \get, \/scripts, (req, res) ->
            err, scripts <- to-callback do ->
                if scripts == null
                    json-string <- bindP (from-error-value-callback read-file) "#__dirname/data/scripts.json", \utf8
                    scripts := JSON.parse json-string
                    returnP scripts
                else
                    returnP scripts
            return die res, err if !!err

            search-string = (req?.query?.q ? "").to-lower-case!

            res.set \content-type, \application/javascript
            res.end do 
                scripts
                    |> filter -> !!it?.name and !!it?.value
                    |> map ({name, value}:script) ->
                        {} <<< script <<< 
                            index: [name, value] 
                                |> map -> it.index-of search-string
                                |> filter (> -1)
                                |> minimum
                    |> filter -> !!it.index
                    |> map ({name, value}) -> {name, value}
                    |> take 20
                    |> pretty
        ...