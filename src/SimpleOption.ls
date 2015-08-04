{filter, find, map} = require \prelude-ls
{partition-string} = require \prelude-extension
React = require \react
{div, input, span} = React.DOM

module.exports = React.create-class do

    display-name: \SimpleOption

    statics:

        # [SimpleOption] -> String -> [SimpleOption]
        filter: (list, search) ->
            list
                |> filter -> !!it.label
                |> map ({label, value}) -> {label, value, partitions: (partition-string label.to-lower-case!, search?.to-lower-case!)}
                |> filter (.partitions.length > 0)

    # render :: a -> ReactElement
    render: ->

        {on-click, on-mouse-over, on-mouse-out, focused, index, label, value, add-options, new-option, partitions} = @props

        # SimpleOption
        div do 
            {
                class-name: "simple-option #{if focused then \focused else ''}"
                on-click
                on-mouse-over
                on-mouse-out
            }
            if add-options and (index == 0 and !!new-option)
                span null, "Add #{label}..."
            else
                partitions |> map ([start, end, highlight]) ~> 
                    span do
                        if highlight then {class-name: \highlight} else null
                        label.substring start, end


