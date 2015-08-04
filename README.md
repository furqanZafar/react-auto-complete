# Install

`sudo npm install react-auto-complete`

# Usage

```
...
React.create-element do
    AutoComplete
    value: @state.selected-fruit
    options: <[apple banana grapes strawberry pineapple orange mango]> 
        |> map (fruit) -> {label: fruit, value: fruit}
    on-change: (value) ~> @set-state selected-fruit: value
...
```