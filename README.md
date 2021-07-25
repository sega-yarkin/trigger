# Trigger
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/sega-yarkin/trigger/Elixir%20Tests?style=flat-square)](https://github.com/sega-yarkin/trigger/actions/workflows/elixir.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/trigger.svg?style=flat-square)](https://hex.pm/packages/trigger)
[![Coveralls](https://img.shields.io/coveralls/github/sega-yarkin/trigger?style=flat-square)](https://coveralls.io/github/sega-yarkin/trigger?branch=master)
[![codebeat badge](https://codebeat.co/badges/6d3a8c56-976b-45c8-bca6-dd87720b1f03)](https://codebeat.co/projects/github-com-sega-yarkin-trigger-master)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)

A simple way to sync between processes. Especially useful when writing ExUnit tests.

## Installation

The package can be installed by adding `trigger` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:trigger, "~> 1.0"},
  ]
end
```

Documentation can be found at [https://hexdocs.pm/trigger](https://hexdocs.pm/trigger).

# Usage

First, you need to create a trigger:
```elixir
iex(1)> trigger = Trigger.new()
%Trigger{receiver: #PID<0.200.0>, ref: #Reference<0.602029420.2269642755.58891>}
```
The trigger contains pid of a signal receiver and an unique reference.

To fire the trigger (usually from another process):
```elixir
iex(2)> spawn(fn -> Trigger.fire(trigger, "data") end)
#PID<0.209.0>
```
An arbitrary data can be sent with the trigger signal (default `nil`).

To wait until the trigger is fired:
```elixir
iex(3)> {sender, data} = Trigger.wait(trigger)
{#PID<0.209.0>, "data"}
```


It is also possible to send arbitrary data back to trigger sender:
```elixir
iex(1)> trigger = Trigger.new()
%Trigger{
  receiver: #PID<0.233.0>,
  ref: #Reference<0.785945778.3082813446.171011>
}
iex(2)> spawn(fn ->
...(2)>   "Hello, world" = Trigger.fire_wait(trigger, "world")
...(2)> end)
#PID<0.238.0>
iex(3)> {sender, name} = Trigger.wait(trigger)
{#PID<0.238.0>, "world"}
iex(4)> Trigger.reply(trigger, sender, "Hello, #{name}")
:ok
```

In addition, a single trigger can be fired multiple times.
