$ = require \jquery-browserify
{concat-map, filter, map} = require \prelude-ls
{DOM:{a, div, h1, h2}}:React = require \react
AutoComplete = React.create-factory require \../../../src/AutoComplete
require! \./ScriptOption.ls
require! \./StyleOption.ls

App = React.create-class do

    # render :: a -> ReactElement
    render: -> 
        div null,
            div {class-name: \title}, 'React Auto Complete'
            div {class-name: \description}, 'A flexible and beautiful Select input control for ReactJS with multiselect & autocomplete'
            a {class-name: \github-link, href: 'http://github.com/furqanZafar/react-auto-complete', target: \_blank}, 'View project on GitHub'
            h1 null, 'Examples:'

            # SIMPLE AUTOCOMPLETE
            h2 null, 'List of fruits using default item renderer:'
            AutoComplete do
                value: @state.selected-fruit
                options: @state.fruits
                on-change: (value) ~> @set-state selected-fruit: value

            # CUSTOM AUTOCOMPLETE
            h2 {style: {margin-top: \30px}}, 'List of stylesheets using a custom item renderer:'
            AutoComplete do
                value: @state.selected-style
                options: @state.styles
                option-class: StyleOption
                on-change: (value) ~> @set-state selected-style: value

            # AJAX AUTOCOMPLETE
            h2 {style: {margin-top: \30px}}, 'List of scripts fetched from server:'
            AutoComplete do 
                value: @state.selected-script
                options: @state.scripts
                option-class: ScriptOption
                on-change: (value) ~>
                    @set-state selected-script: value
                    @request.abort! if !!@request
                    @request = $.getJSON "scripts?q=#{value}"
                        ..done (scripts) ~> @set-state {scripts}

            div {class-name: \copy-right}, 'Copyright © Furqan Zafar 2014. MIT Licensed.'

    # get-initial-state :: a -> UIState
    get-initial-state: ->
        scripts: []
        selected-script: "http://cdnjs.cloudflare.com/ajax/libs/moment.js/2.9.0/moment.min.js"

        fruits: <[apple banana grapes strawberry pineapple orange mango]> |> map (fruit) -> {label: fruit, value: fruit}
        selected-fruit: "apple"

        styles: []
        selected-style: "http://cdnjs.cloudflare.com/ajax/libs/normalize/3.0.2/normalize.min.css"

    # component-will-mount :: a -> Void
    component-will-mount: !->
        $.getJSON "data/styles.json"
            ..done (styles) ~> @set-state {styles}
            ..fail -> console.log "unable to fetch styles"
        (require \socket.io-client) "http://#{window.location.hostname}:8001"
            ..on \build-start, ~> @.set-state {building: true}
            ..on \build-complete, -> window.location.reload!


React.render do
    React.create-element App, null
    document.body