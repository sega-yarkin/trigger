defmodule TriggerTest do
  use ExUnit.Case, async: true
  doctest Trigger

  test "new/1" do
    pid = self()
    assert %{receiver: ^pid} = Trigger.new()
    pid = spawn(fn -> :ok end)
    assert %{receiver: ^pid} = Trigger.new(receiver: pid)
    assert is_reference(Trigger.new().ref)
    # Test default struct constructor
    struct(Trigger, [])
  end

  test "fire/2" do
    trigger = Trigger.new()
    ref = trigger.ref
    pid = self()
    assert Trigger.fire(trigger) == :ok
    assert_received {^ref, ^pid, nil}
    assert Trigger.fire(trigger, :data) == :ok
    assert_received {^ref, ^pid, :data}
  end

  test "wait/2" do
    trigger = Trigger.new()
    pid = self()
    assert Trigger.fire(trigger, :data) == :ok
    assert Trigger.wait(trigger) == {pid, :data}
    assert {:timeout, _} = catch_exit(Trigger.wait(trigger, 100))
  end

  test "reply/3" do
    trigger = Trigger.new()
    ref = trigger.ref
    assert Trigger.reply(trigger, self()) == :ok
    assert_received {^ref, nil}
    assert Trigger.reply(trigger, self(), :data) == :ok
    assert_received {^ref, :data}
  end

  test "simple workflow" do
    trigger = Trigger.new()
    pid = spawn_link(fn ->
      Trigger.fire(trigger, :hello)
    end)
    assert {^pid, :hello} = Trigger.wait(trigger)
    refute_received _
  end

  test "two way data" do
    trigger = Trigger.new()
    pid = spawn_link(fn ->
      assert Trigger.fire_wait(trigger, :hello) == :world
    end)
    assert {^pid, :hello} = Trigger.wait(trigger)
    assert Trigger.reply(trigger, pid, :world) == :ok
    refute_receive _, 100
  end

  test "fire_wait/3" do
    trigger = Trigger.new()
    test_pid = self()
    pid = spawn_link(fn ->
      assert Trigger.fire_wait(trigger, :hello) == :world
      send(test_pid, :post_fire)
    end)
    refute_receive :post_fire, 100
    assert {^pid, :hello} = Trigger.wait(trigger)
    assert Trigger.reply(trigger, pid, :world) == :ok
    assert_receive :post_fire, 100

    assert {:timeout, _} = catch_exit(Trigger.fire_wait(trigger, :hello, 100))
  end

  test "wait_reply/3" do
    trigger = Trigger.new()
    _pid = spawn_link(fn ->
      assert Trigger.fire_wait(trigger, :hello) == :world
    end)
    assert Trigger.wait_reply(trigger, :world) == :hello
    refute_receive _, 100

    assert {:timeout, _} = catch_exit(Trigger.wait_reply(trigger, :hello, 100))
  end
end
