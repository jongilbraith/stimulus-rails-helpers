# Rails Helpers for Stimulus

Some helpers to help tame the task of wrangling Stimulus' `data` attributes.

At its core it revolves around a simple short hand notation for describing the various attributes you have to generate when wiring Stimulus controllers into the DOM.

Design philosophy:

* Just use camel case
* Just use symbols (well almost, for all the Stimulus parts at least)
* Leverage hashes to describe Stimulus attributes in an intuitive, terser format

No validation or sanity checking, it's purely a shorthand. It won't warn you if you've got a typo in an attribute or anything like that. But hopefully this makes it easier to avoid these kinds of issues.

## How it works

Two core methods for Stimulus attributes, with one more for namespaces, then two more that are identical counterparts for the first two, just for when using namespaces.

## The two methods - create an element or generate data attributes, for adding to another element

Create an element with the helper `stimulus_element` (or `stim_el` for short). Pass a block if you have content to go inside the element. Much like `content_tag` (that's what's used underneath).

Generate attributes with the helper `stimulus_data` (or `stim_data` for short).

Both of these use pretty much the same arguments, other than the fact that `stimulus_element` has an optional first argument of what type of element it is (it defaults to `:div`) and it can take a block.

When using the namespace functionality (documented at the end of this README) you yield an object on which you call two methods that are the direct equivalent of these two methods.

## Example

Simple example of a Stimulus controller declared on a wrapper div, that watches a field via the `refreshCount` action and updates a message in a div with target of `field`

```
<%= stimulus_element controller: :word_count, class: "form-group" do %>
  <%=
    text_field_tag :user_name,
      params[:user_name],
      data: stimulus_data(actions: { word_count: :refresh_count }),
      class: "input text-field"
  %>
  <%= stimulus_element targets: { word_count: :field }, class: "word-count-message" %>
<% end %>
```

This will produce something along the lines of:

```
<div data-controller"word-count" class="form-group">
  <input type="text" name="user_name" value="jon" data-action="word-count#refreshCount" class="input text-field">
  <div data-word-count-target="field" class="word-count-message"></div>
</div>
```

That's all there is to it. You just need to know what other arguments you can pass to `stimulus_element` and `stimulus_data` to handle other types of Stimulus attributes.

## The arguents in depth

### `controllers`

Pass in an array of controller names and you'll get the `data-controller` attribute with the arguments provided.

So for example `controllers: [:word_count, :image_upload]` gets you:

```
data-controller="word-count image-upload"
```

### `targets`

Pass in a correctly structured hash and you get the expected data attributes for the targets.

The format is `controller_name: :target_name` for a single target, or `controller_name: [:target_name, :another_target_name]`

So for example:

```
targets: {
  calculate_tax: :tax_amount,
  calculate_total: [:sub_total, :grand_total]
}
```

Gets you:

```
data-calculate-tax-target="taxAmount"
data-calculate-total-target="subTotal"
data-calculate-total-target="grandTotal"
```

### `actions`

Pass in a correctly structured hash (for multiple actions for multiple controllers) and you get the expected data attribute for the actions.

The format is `controller_name: :action_name` for the default event, or `controller_name: { event: :action_name }` for other events.

So for example:

```
actions: {
  calculate_tax: :refresh_total,
  calculate_total: { blur: :warn_if_exceeds_balance }
}
```

Gets you:

```
data-action="calculate-tax#refreshTotal blur->calculate-total#warnIfExceedsBalance"
```

### `values`

Pass in a correctly structured hash and you get the expected data attributes for the values.

The format is `controller_name: { value_name: :value_value }`

So for example: `values: { calculate_tax: { tax_rate: 20 } }`

Gets you:

```
data-calculate-tax-tax-rate-value="20"
```

### `outlets`

Pass in a correctly structured hash and you get the expected data attributes for the outlets.

The format is `source_controller_name: { target_controller_name: :target_controller_selector }`

So for example:

```
outlets: {
  calculate_tax: {
    calculate_total: "#calculate-total"
  }
}
```

Gets you:

```
data-calculate-tax-calculate-total-outlet="#calculate-total"
```

# Additional attributes

In both methods, any additional arguments passed in will be passed on as other attributes (`stimulus_element`) or other data attributes (`stimulus_data`).

E.g.

```
stimulus_element(:span, targets: { calculate_tax: :tax_amount }, class: "highlight")
```

Gets you:

```
<span data-calculate-tax-target="taxAmount" class="highlight"></span>
```

Or

```
<%=
  text_field_tag :user_name,
    params[:user_name],
    data: stimulus_data(
      actions: { word_count: :refresh_count },
      user_tracking_id: 1234
    ),
    class: "input text-field"
%>
```

```
<input type="text" name="user_name" value="jon" data-action="word-count#refreshCount" data-user-tracking-id="1234" class="input text-field">
```

# Namespaces

The quick and dirty way if applying a namespace is to just pass a `namespace` param when calling `stimulus_element` or `stimulus_data`. However in most scenarios that will likely get repetetive.

To declare your namespace once and have it apply automatically you can use a namespace scope.

## Namespace scopes

You can call the `stimulus_namespace` helper (or `stim_ns` for short) with a any number of arguments and it will yield an object for each of them, each representing a separate namespace.

On the yielded object(s) you call `element` (or `el` for short) or `data` (short enough, no alias) on them and they work exactly the same way as the helpers described before, except all outputs will have the prefix attached.

Like so:

```
<%= stimulus_namespace :admin do |stimulus| %>
  <%= stimulus.element controller: :word_count do %>
    text_field_tag :user_name,
      params[:user_name],
      data: stimulus.data(actions: { word_count: :refresh_count }),
      class: "input text-field"
  %>
  <%= stimulus_element targets: { word_count: :field }, class: "word-count-message" %>
<% end %>
```

This will produce something along the lines of:

```
<div data-controller"admin--word-count" class="form-group">
  <input type="text" name="user_name" value="jon" data-action="admin--word-count#refreshCount class="input text-field">
  <div data-admin--word-count-target="field" class="word-count-message"></div>
</div>
```

With multiple namespaces:

```
<%= stimulus_namespace :one_namespace, :another_namespace do |one, another| %>
  .
  .
  .
<% end %>
```

And you can describe deeper nested namespaces too:

```
<%= stimulus_namespace parent: :child do |stimulus| %>
  .
  .
  .
<% end %>
```

Which will apply a prefix of `parent--child--`.

Finally, arrays work too:

```
<%= stimulus_namespace [:first, :second, :third] do |stimulus| %>
  .
  .
  .
<% end %>
```

Which produces `first--second--third--`.

# Problems

It's occurred to me that if you have overlapping namespaces you'll likely want to populate attributes for both of them on the same element, and my current approach doesn't take that into account.

You'd have to call `stimulus_data` and merge the output of that into other calls of `stimulus_element` and `stimulus_data`, which on second thoughts might not be so janky after all.

But I'll be thinking about a good solution for that.
