$ = require \jquery-browserify
{concat-map, filter, map} = require \prelude-ls
{DOM:{a, div, h1, h2}}:React = require \react
AutoComplete = require \../../src/AutoComplete.ls
LibraryOption = require \./LibraryOption.ls

App = React.create-class do

    render: -> 
        div null,
            div {class-name: \title}, 'React Auto Complete'
            div {class-name: \description}, 'A flexible and beautiful Select input control for ReactJS with multiselect & autocomplete'
            a {class-name: \github-link, href: 'http://github.com/furqanZafar/react-select/tree/develop', target: \_blank}, 'View project on GitHub'
            h1 null, 'Examples:'

            h2 null, 'Simple Auto Complete:'

            # SIMPLE AUTOCOMPLETE
            React.create-element do
                AutoComplete
                value: @state.selected-fruit
                options: <[apple banana grapes strawberry pineapple orange mango]> |> map (fruit) -> {label: fruit, value: fruit}
                on-change: (value) ~> @set-state selected-fruit: value

            h2 null, 'Custom Auto Complete:'

            # LIBRARY AUTOCOMPLETE
            React.create-element do
                AutoComplete
                value: @state.selected-library
                options: @state.libraries
                option-class: LibraryOption
                on-change: (value) ~> @set-state selected-library: value

            div {class-name: \copy-right}, 'Copyright © Furqan Zafar 2014. MIT Licensed.'

    get-initial-state: ->
        selected-fruit: "apple", selected-library: "http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.7.0/underscore-min.js", libraries: []

    component-will-mount: ->
        $.getJSON "http://#{window.location.host}/libraries.json"
            ..done (libraries) ~> @set-state {libraries}
            ..fail -> console.log "unable to fetch libraries"


React.render do
    React.create-element App, null
    document.body