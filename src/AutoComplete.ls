{filter, map} = require \prelude-ls
{clamp} = require \prelude-extension
{DOM:{div, input, span}}:React = require \react
require! \./SimpleOption

module.exports = React.create-class do

    display-name: \AutoComplete

    # render :: a -> ReactElement
    render: ->
        {
            props: {options, placeholder-text, option-class}
            state: {focused-option, open}
        } = @

        # MULTISELECT
        div do 
            class-name: "auto-complete #{if open then 'open' else ''}"
            div do 
                {class-name: \control, key: \control, style: @props.style ? {}}

                # SEARCH INPUT BOX
                input do
                    ref: \search
                    type: \text
                    value: @props.value
                    on-change: ({current-target:{value}}) ~>
                        @set-state do
                            focused-option: 0
                            open: @state.open or (value.length > 0)

                        # let the parent component know that its time to update the value
                        @props.on-change value

                    on-key-down: ({which}:e) ~>
                        match which
                            | 13 => 
                                @set-state {open: false}, ~>
                                    @select-option @state.focused-option
                                    @focus!
                            | 27 =>
                                if @state.open
                                    @set-state open: false
                                else
                                    @reset!
                                @focus!
                            | 38 => @focus-adjacent-option -1
                            | 40 => @focus-adjacent-option 1
                            | _ => return
                        e.prevent-default!
                        e.stop-propagation!

                # RESET BUTTON
                div do 
                    class-name: \reset
                    on-click: ~> @reset!; @focus!; false
                    \×

                # ARROW ICON
                div {class-name: \arrow}, null

            # LIST OF OPTIONS
            if open
                div do 
                    {class-name: \options, key: \options}
                    (@filter-options @props.value) |> map ({index, value}:option-object) ~>
                        React.create-element do 
                            option-class or SimpleOption
                            {} <<< option-object <<<
                                key: "#{value}"
                                ref: "option-#{index}"
                                focused: index == focused-option
                                on-click: ~>
                                    @set-state {open: false}, ~>
                                        @select-option index
                                        @focus!
                                    false
                                on-mouse-over: ~> @set-state focused-option: index
                                on-mouse-out: ~> @set-state focused-option: -1
    
    # get-initial-state :: a -> UIState
    get-initial-state: -> 
        focused-option: 0, open: false

    # component-did-update :: a -> Void
    component-did-update: !->
        return if @state.focused-option == -1

        {parent-element}:option-element? = @?.refs?["option-#{@state.focused-option}"]?.getDOMNode!
        return if !option-element

        option-height = option-element.offset-height - 1

        if (option-element.offset-top - parent-element.scroll-top) > parent-element.offset-height
            parent-element.scroll-top = option-element.offset-top - parent-element.offset-height + option-height

        else if (option-element.offset-top - parent-element.scroll-top + option-height) < 0
            parent-element.scroll-top = option-element.offset-top   

    # filter-options :: String -> [Option]
    filter-options: (search) ->
        result = (@props.option-class or SimpleOption).filter @props.options, search
        [0 til result.length] |> map (index) -> result[index] <<< {index}

    # focus :: a -> Void
    focus: !->
        @refs.search.getDOMNode!.focus!

    # focus-adjacent-option :: Number -> Void
    focus-adjacent-option: (direction) !->
        {values} = @props
        @set-state do
            focused-option: clamp (@state.focused-option + direction), 0, (@filter-options @props.value).length - 1
            open: true

    # reset : a -> Void
    reset: !-> @props.on-change ""
        
    # select-option :: Number -> Void
    select-option: (index) !->
        filtered-options = @filter-options @props.value
        {value}:option? = filtered-options?[index]
        if !!value
            @props.on-change value

