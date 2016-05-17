# GenDelegate
[![Build Status](https://img.shields.io/travis/zackehh/gen_delegate.svg)](https://travis-ci.org/zackehh/gen_delegate) [![Hex.pm Version](https://img.shields.io/hexpm/v/gen_delegate.svg)](https://hex.pm/packages/gen_delegate) [![Documentation](https://img.shields.io/badge/docs-latest-yellowgreen.svg)](https://hexdocs.pm/gen_delegate/readme.html)

There's a very common pattern inside `GenServer` modules in which several functions are defined internally, and then they're also required for use by external processes. This module is an attempt to lessen the overhead of this through the use of Macros. It might be that you see no point in this module (which is fair enough), but I use it quite commonly and felt it should be made available as it comes in handy.

## Table of Contents

- [Installation](#installation)
- [Example Usage](#example-usage)
- [Benefits](#benefits)
- [Changing State](#changing-state)
- [Sending Messages](#sending-messages)
- [Contributions](#contributions)

## Installation

`GenDelegate` can be installed via Hex using the following:

  1. Add `gen_delegate` to your list of dependencies in `mix.exs`:

        def deps do
          [{:gen_delegate, "~> 0.0.1"}]
        end

## Example Usage

Suppose you have an implementation of a `GenServer` which operates on a state which is a `Map`. If we were to pretend that `Enum.count/1` did not exist, you may have a function internally named `size/1`, which accepts the current state of the server. You could invoke this function via:

```elixir
iex> size(state)
10
```

Now, imagine you have a main process talking to this server in order to work on the keys and values in the Map. This process also needs to be able to find the size of the Map. Typically you would implement a `handle_call/3` which just wraps `size/1`:

```elixir
def handle_call({ :size }, _ctx, state) do
  { :reply, size(state), state }
end
```

This leads to a lot of wasted and unnecessary code in the scenario where you have a lot of internal re-use. In the case of `GenDelegate`, you can simply provide a delegate definition:

```elixir
# remember to use it or import it
use GenDelegate

# definition matches the function head
gen_delegate size(state), type: [ :call ]
```

This provides an easy way to bind any internal functions to be externally accessible. The line above will provide the exact definition as demonstrated above. This reduces the amount of overhead involved in exposing a function. If you wish to name your state something other than "state", you can do so using the `alias` option.

```elixir
gen_delegate size(options), type: [ :call ], alias: :options
```

## Benefits

The reason this is totally worth it is that these delegates allow you to expose functions as both synchronous and asynchronous. Consider the below:

```elixir
def do_something(state) do
  :timer.sleep(5000)
  IO.inspect(state)
end

gen_delegate do_something(state), type: [ :call, :cast ]
```

Now I can call `do_something/1` with either a `call` or `cast` operation. In the case that I use a blocking `call/2` operation, any values will be returned. However in the case that I use a `cast/2` call, no values are returned and there's no blocking. This is extremely useful if you want the user to be able to easily determine if they want your library to block or not. Any of `:call`, `:cast` and `:info` are supported in the list, and a single delegate does not have to be wrapped in a list.

## Changing State

Due to the way `gen_delegate` works, you have to explicitly inform if you want to change the internal state or not. This is done via passing a delegate result containing the new state. A delegate result is simply a tuple in various forms, with the first element equal to `:delegate`. How it looks will differ upon whether you're calling or casting.

In the case you're calling you may use any of these methods:

```elixir
"string"                    # any normal result is returned as is and the state is not changed
{ :delegate, new_state }    # this will bind the new_state variable as the state, and return `nil`
{ :delegate, 1, new_state } # this will bind the new_state variable as the state, but will return `1`
```

In the case you're casting (or using `handle_info`), the following rules apply:

```elixir
"string"                    # any normal result is returned as is and the state is not changed
{ :delegate, new_state }    # this will bind the new_state variable as the state
{ :delegate, 1, new_state } # this will bind the new_state variable as the state, and will ignore `1`
```

It should be noted that this use case will be surprisingly rare, as you typically only internalize functions which have no effect on state (unless you're chaining them).

## Sending Messages

Delegates work strictly with tuple messages for uniformity, and the function heads determine what your message should look like. This is in the form of `{ func_name, args... }`. For example if you were to use the `do_something/1` example above, you would simply send `GenServer.call(pid, { :do_something })`. Any arguments related to the `state` should not be passed as these arguments are wired automatically.

```elixir
# here's our function
def do_something(var_one, state, var_two) do
  "hello world"
end

# delegate through as a call
gen_delegate do_something(var_one, state, var_two), type: :call

# call the function - note that you don't pass any "state" arguments, regardless
# of where they occur, as long as your delegate function head is correctly ordered
GenServer.call(pid, { :do_something, arg_one, arg_two })
```

## Contributions

If you feel something can be improved, or have any questions about certain behaviours or pieces of implementation, please feel free to file an issue. Proposed changes should be taken to issues before any PRs to avoid wasting time on code which might not be merged upstream.

If you *do* make changes to the codebase, please make sure you test your changes thoroughly.

```bash
$ mix test
```
