{partition-string} = require \prelude-extension
{filter, find, map} = require \prelude-ls
{DOM:{div, input, span}}:React = require \react

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
        {focused, label, partitions} = @props
        div do 
            class-name: "simple-option #{if focused then \focused else ''}"
            partitions |> map ([start, end, highlight]) ~> 
                span do
                    {key: start, class-name: if highlight then \highlight else ''}
                    label.substring start, end