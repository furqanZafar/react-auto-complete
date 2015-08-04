{any, filter, find, map} = require \prelude-ls
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class do

    display-name: \LibraryOption

    statics:

        # [LibraryOption] -> String -> [LibraryOption]
        filter: (list, search) ->
            list |> filter ({name, value, tokens}) -> 
                [name, value] |> any -> (it.to-lower-case!.index-of search.to-lower-case!) > -1
                # tokens |> any -> (it.index-of search.to-lower-case!) > -1

    render: ->

        {on-click, on-mouse-over, on-mouse-out, focused, name, value} = @props

        # LibraryOption
        div do 
            {
                class-name: "library-option #{if focused then \focused else ''}"
                on-click
                on-mouse-over
                on-mouse-out
            }
            div {style:{font-weight: \bold}}, name
            div {style:{font-size: \0.8em}}, value