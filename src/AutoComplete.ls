{filter, map} = require \prelude-ls
{clamp} = require \prelude-extension
{DOM:{div, input, span}}:React = require \react
require! \./SimpleOption

module.exports = React.create-class do

    display-name: \AutoComplete

    # render :: a -> ReactElement
    render: ->
        {
            props: {options, placeholder, option-class}
            state: {focused-option, open}
        } = @

        # MULTISELECT
        div do 
            class-name: "auto-complete #{if open then 'open' else ''} #{if @props?.class-name then @props.class-name else ''}"
            div do 
                {class-name: \control, key: \control}

                # SEARCH INPUT BOX
                input do
                    placeholder: placeholder
                    ref: \search
                    type: \text
                    value: @props.value
                    on-change: ({current-target:{value}}) ~>
                        @props.on-change value
                        @set-state focused-option: 0, open: value.length > 0
                    on-key-down: ({which}:e) ~>

                        # do not prevent default in case of TAB key
                        if which == 9
                            @set-state open: false, ~>
                                @props.on-blur @props.value if !!@props?.on-blur

                        # for all the following keys prevent default action after processing them
                        else

                            match which

                                # ENTER
                                | 13 => 
                                    @set-state {open: false}, ~>
                                        @select-option @state.focused-option
                                        @focus!

                                # ESCAPE
                                | 27 =>
                                    if @state.open
                                        @set-state open: false
                                    else
                                        @reset!
                                    @focus!

                                # UP
                                | 38 => @focus-adjacent-option -1

                                # DOWN
                                | 40 => @focus-adjacent-option 1
                                | _ => return
                            
                            e.prevent-default!
                            e.stop-propagation!

                # RESET BUTTON
                if @props.value.length > 0
                    div do 
                        class-name: \reset
                        on-click: (e) ~> 
                            @set-state open: false
                            @reset!
                            @focus!
                            e.prevent-default!
                            e.stop-propagation!
                        \×

            # LIST OF OPTIONS
            if open
                div do 
                    {class-name: \options, key: \options}
                    (@filter-options @props.value) |> map ({index, value}:option-object) ~>
                        div do 
                            key: value
                            ref: "option-#{index}"
                            on-click: (e) ~>
                                @set-state open: false, ~>
                                    @select-option index
                                    @focus!
                                e.prevent-default!
                                e.stop-propagation!
                            on-mouse-over: ~> @set-state focused-option: index
                            on-mouse-out: ~> @set-state focused-option: -1
                            React.create-element do 
                                option-class or SimpleOption
                                {} <<< option-object <<<
                                    key: value                                    
                                    focused: index == focused-option
    
    # get-initial-state :: a -> UIState
    get-initial-state: -> focused-option: 0, open: false

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
    focus: !-> @refs.search.getDOMNode!.focus!

    # focus-adjacent-option :: Number -> Void
    focus-adjacent-option: (direction) !->
        {values} = @props
        @set-state open: true, focused-option: clamp (@state.focused-option + direction), 0, (@filter-options @props.value).length - 1

    # reset : a -> Void
    reset: !-> @props.on-change ""
        
    # select-option :: Number -> Void
    select-option: (index) !->
        filtered-options = @filter-options @props.value
        {value}:option? = filtered-options?[index]
        @props.on-change value if !!value