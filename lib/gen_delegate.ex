defmodule GenDelegate do
  @moduledoc """
  This module provides delegation abilities to a developer in order to expose
  local functions from within a `GenServer`.
  """

  @doc """
  Allows delegation of an internal function to a `GenServer` interface.

  Delegation should be used when binding a function needed locally against a
  function which is also needed remotely.

  ## Options

    * `:alias` - a name to refer to the state as, instead of `state`.
    * `:type` - the type of delegate this is. Any of `:cast`, `:call` and `:info`.

  ## Examples

      gen_delegate function(var_one, state), type: :cast
      gen_delegate function(var_one, state), type: [ :call, :cast ]
      gen_delegate function(var_one, names), type: :info, alias: :names

  """
  defmacro gen_delegate(head, options \\ []) do
    { func_name, args } = Macro.decompose_call(case head do
      { :when, _, [func_head | _] } -> func_head
      func_head -> func_head
    end)

    state_name = Keyword.get(options, :alias, :state)
    norm_types =
      options
      |> Keyword.get(:type, [])
      |> List.wrap

    arguments = Enum.filter(args, &(!match?({ ^state_name, _, _ }, &1)))
    state_var = Macro.var(state_name, nil)
    g_message = quote do
      { unquote(func_name), unquote_splicing(arguments) }
    end

    call_body = quote do
      case unquote(func_name)(unquote_splicing(args)) do
        { :delegate, state } ->
          { :reply, nil, state }
        { :delegate, result, state } ->
          { :reply, result, state }
        result ->
          { :reply, result, unquote(state_var) }
      end
    end

    cast_info_body = quote do
      case unquote(func_name)(unquote_splicing(args)) do
        { :delegate, state } ->
          { :noreply, state }
        { :delegate, _result, state } ->
          { :noreply, state }
        _result ->
          { :noreply, unquote(state_var) }
      end
    end

    called_quote = if Enum.member?(norm_types, :call) do
      quote do
        def handle_call(unquote(g_message), _, unquote(state_var)) do
          unquote(call_body)
        end
      end
    end

    casted_quote = if Enum.member?(norm_types, :cast) do
      quote do
        def handle_cast(unquote(g_message), unquote(state_var)) do
          unquote(cast_info_body)
        end
      end
    end

    infoed_quote = if Enum.member?(norm_types, :info) do
      quote do
        def handle_info(unquote(g_message), unquote(state_var)) do
          unquote(cast_info_body)
        end
      end
    end

    quote do
      unquote(called_quote)
      unquote(casted_quote)
      unquote(infoed_quote)
    end
  end

  # Allow the ability to use this module
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end

end
