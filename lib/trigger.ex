defmodule Trigger do
  @moduledoc """
  A simple way to sync between processes.
  """

  @enforce_keys [:ref, :receiver]
  defstruct [:ref, :receiver]

  @opaque t() :: %Trigger{
    ref: reference(),
    receiver: pid(),
  }

  @spec new(options) :: t
        when options: [
          receiver: pid(),
        ]
  def new(opts \\ []) do
    receiver = Keyword.get(opts, :receiver, self())
    ref = make_ref()
    %Trigger{ref: ref, receiver: receiver}
  end

  @spec fire(t, term) :: :ok
  def fire(%Trigger{} = trigger, data \\ nil) do
    send(trigger.receiver, {trigger.ref, self(), data})
    :ok
  end

  @spec fire_wait(t, term, timeout) :: term | no_return
  def fire_wait(%Trigger{ref: ref} = trigger, data \\ nil, timeout \\ :infinity) do
    fire(trigger, data)
    receive do
      {^ref, data} -> data
    after
      timeout -> exit({:timeout, {__MODULE__, :fire_wait, [trigger, data, timeout]}})
    end
  end

  @spec wait(t, timeout) :: {pid, term} | no_return
  def wait(%Trigger{ref: ref} = trigger, timeout \\ :infinity) do
    receive do
      {^ref, from, data} -> {from, data}
    after
      timeout -> exit({:timeout, {__MODULE__, :wait, [trigger, timeout]}})
    end
  end

  @spec reply(t, pid, term) :: :ok
  def reply(%Trigger{ref: ref}, to, reply \\ nil) do
    send(to, {ref, reply})
    :ok
  end

  @spec wait_reply(t, term, timeout) :: term | no_return
  def wait_reply(%Trigger{} = trigger, data \\ nil, timeout \\ :infinity) do
    {from, data_in} = wait(trigger, timeout)
    reply(trigger, from, data)
    data_in
  end

end
