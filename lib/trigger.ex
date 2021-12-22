defmodule Trigger do
  @moduledoc """
  A simple way to sync between processes.
  """

  @enforce_keys [:ref, :receiver]
  defstruct [:ref, :receiver]

  @typedoc """
  A Trigger data type.
  """
  @opaque t() :: %Trigger{
    ref: reference(),         # unique reference for the trigger
    receiver: Process.dest(), # process awaiting on the trigger
  }

  @doc """
  Creates a new Trigger.

  ## Options

    * `receiver` - configure an event receiver, defaults to `self()`

  ## Examples

      iex> Trigger.new()
      %Trigger{...}
  """
  @spec new(options) :: t
        when options: [
          receiver: Process.dest(),
        ]
  def new(opts \\ []) do
    receiver = Keyword.get(opts, :receiver, self())
    ref = make_ref()
    %Trigger{ref: ref, receiver: receiver}
  end

  @doc """
  Sends a new event with arbitrary data to the receiver.

  ## Examples

      iex> trigger = Trigger.new()
      %Trigger{...}
      iex> Trigger.fire(trigger)
      :ok
      iex> Trigger.wait(trigger)
      {#PID<0.257.0>, nil}
  """
  @spec fire(t, term) :: :ok
  def fire(%Trigger{receiver: receiver, ref: ref}, data \\ nil) do
    send(receiver, {ref, self(), data})
    :ok
  end

  @doc """
  Sends a new event with arbitrary data to the receiver and waits for a reply.

  ## Examples

      iex> trigger = Trigger.new()
      %Trigger{...}
      iex> pid = spawn(fn ->
      ...>   "Hello, world" = Trigger.fire_wait(trigger, "world")
      ...> end)
      #PID<0.262.0>
      iex> {sender, name} = Trigger.wait(trigger)
      {#PID<0.262.0>, "world"}
      iex> Process.alive?(pid)
      true
      iex> Trigger.reply(trigger, sender, "Hello, \#{name}")
      :ok
      iex> Process.alive?(pid)
      false
  """
  @spec fire_wait(t, term, timeout) :: term | no_return
  def fire_wait(%Trigger{ref: ref} = trigger, data \\ nil, timeout \\ :infinity) do
    fire(trigger, data)

    receive do
      {^ref, data} -> data
    after
      timeout -> exit({:timeout, {__MODULE__, :fire_wait, [trigger, data, timeout]}})
    end
  end

  @doc """
  Waits for an event.

  For examples see `fire/2` or `fire_wait/3`.
  """
  @spec wait(t, timeout) :: {pid, term} | no_return
  def wait(%Trigger{ref: ref} = trigger, timeout \\ :infinity) do
    receive do
      {^ref, from, data} -> {from, data}
    after
      timeout -> exit({:timeout, {__MODULE__, :wait, [trigger, timeout]}})
    end
  end

  @doc """
  Sends a reply back to the process which sent the event.
  """
  @spec reply(t, pid, term) :: :ok
  def reply(%Trigger{ref: ref}, to, reply \\ nil) do
    send(to, {ref, reply})
    :ok
  end

  @doc """
  Waits fot an event and sends a reply back right away.

  This is useful to have a two-way sync between processes, so event-sender knows
  that the receiver has got the event.

  ## Examples

      iex> trigger = Trigger.new()
      %Trigger{...}
      iex> test = fn -> IO.inspect({self(), :erlang.unique_integer([:positive, :monotonic])}); :ok end
      #Function<...>
      iex> test.()
      {#PID<0.247.0>, 1}
      iex> spawn(fn ->
      ...>   test.()
      ...>   "pong" = Trigger.fire_wait(trigger, "ping")
      ...>   test.()
      ...> end)
      {#PID<0.258.0>, 2}
      #PID<0.258.0>
      iex> "ping" = Trigger.wait_reply(trigger, "pong"); test.()
      {#PID<0.247.0>, 3}
      {#PID<0.258.0>, 4}
  """
  @spec wait_reply(t, term, timeout) :: term | no_return
  def wait_reply(%Trigger{} = trigger, data \\ nil, timeout \\ :infinity) do
    {from, data_in} = wait(trigger, timeout)
    reply(trigger, from, data)
    data_in
  end

end
