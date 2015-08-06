{any, filter, find, map} = require \prelude-ls
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class do

    display-name: \ScriptOption

    statics:

        # [ScriptOption] -> String -> [ScriptOption]
        filter: (list, search) -> list

    # a -> ReactElement
    render: ->

        {focused, name, value} = @props

        # ScriptOption
        div do 
            class-name: "script-option #{if focused then \focused else ''}"
            div {style:{font-weight: \bold}}, name
            div {style:{font-size: \0.8em}}, value