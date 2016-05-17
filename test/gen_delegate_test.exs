defmodule GenDelegateTest do
  use PowerAssert

  test "calling with no change of state" do
    { :ok, pid } = start("barry")

    assert(GenServer.call(pid, { :reverse }) == "yrrab")
  end

  test "calling with a change of state" do
    { :ok, pid } = start("barry")

    assert(GenServer.call(pid, { :change, "trevor" }) == nil)
    assert(GenServer.call(pid, { :reverse }) == "rovert")
  end

  test "calling with a change of state and a return value" do
    { :ok, pid } = start("barry")

    assert(GenServer.call(pid, { :change_and_return, "trevor" }) == "trevor")
  end

  test "calling with a change of state and an alias" do
    { :ok, pid } = start("barry")

    assert(GenServer.call(pid, { :change_with_alias, "trevor" }) == "trevor")
  end

  test "casting with no change of state" do
    { :ok, pid } = start("barry")

    assert(GenServer.cast(pid, { :reverse }) == :ok)
  end

  test "casting with a change of state" do
    { :ok, pid } = start("barry")

    assert(GenServer.cast(pid, { :change, "trevor" }) == :ok)
    assert(GenServer.call(pid, { :reverse }) == "rovert")
  end

  test "casting with a change of state and a return value" do
    { :ok, pid } = start("barry")

    assert(GenServer.cast(pid, { :change_and_return, "trevor" }) == :ok)
    assert(GenServer.call(pid, { :reverse }) == "rovert")
  end

  test "casting with a change of state and an alias" do
    { :ok, pid } = start("barry")

    assert(GenServer.cast(pid, { :change_with_alias, "trevor" }) == :ok)
    assert(GenServer.call(pid, { :reverse }) == "rovert")
  end

  test "info with no change of state" do
    { :ok, pid } = start("barry")

    msg = { :reverse }

    assert(send(pid, msg) == msg)
  end

  test "info with a change of state" do
    { :ok, pid } = start("barry")

    msg = { :change, "trevor" }

    assert(send(pid, msg) == msg)
    assert(GenServer.call(pid, { :reverse }) == "rovert")
  end

  test "info with a change of state and a return value" do
    { :ok, pid } = start("barry")

    msg = { :change_and_return, "trevor" }

    assert(send(pid, msg) == msg)
    assert(GenServer.call(pid, { :reverse }) == "rovert")
  end

  test "info with a change of state and an alias" do
    { :ok, pid } = start("barry")

    msg = { :change_with_alias, "trevor" }

    assert(send(pid, msg) == msg)
    assert(GenServer.call(pid, { :reverse }) == "rovert")
  end

  defp start(options) do
    { :ok, pid } = GenServer.start_link(DelegateTestModule, options, [])

    on_exit("kill #{inspect(pid)}", fn ->
      Process.exit(pid, :normal)
    end)

    { :ok, pid }
  end
end

defmodule DelegateTestModule do
  use GenDelegate

  def init(state) do
    { :ok, state }
  end

  def change(_state, name) do
    { :delegate, name }
  end

  def change_and_return(_state, name) do
    { :delegate, name, name }
  end

  def change_with_alias(_internal_name, name) do
    { :delegate, name, name }
  end

  def reverse(state) do
    String.reverse(state)
  end

  gen_delegate change(state, name), type: [ :call, :cast, :info ]
  gen_delegate change_and_return(state, name), type: [ :call, :cast, :info ]
  gen_delegate change_with_alias(internal_name, name), type: [ :call, :cast, :info ], alias: :internal_name
  gen_delegate reverse(state), type: [ :call, :cast, :info ]

end
