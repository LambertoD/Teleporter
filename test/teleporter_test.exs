defmodule TeleporterTest do
  use ExUnit.Case

  alias Bmup.Teleporter

  test "Add a route to empty portal" do
    route = Teleporter.add_route("Washington", "Atlanta", portal = %{})
    assert route == %{"Washington" => ["Atlanta"], "Atlanta" => ["Washington"]}
  end

  test "Add a route to existing portal, non-existing key" do
    route = Teleporter.add_route("Washington", "Atlanta", %{"Baltimore" => ["Philadelphia"], "Philadelphia" => "Baltimore"})
    assert route == %{"Washington" => ["Atlanta"], "Atlanta" => ["Washington"], "Baltimore" => ["Philadelphia"], "Philadelphia" => "Baltimore"}
  end

  test "Add a route to existing portal, existing key" do
    route = Teleporter.add_route("Washington", "Atlanta", %{"Washington" => ["Baltimore"], "Baltimore" => ["Washington"]})
    assert route == %{"Washington" => ["Atlanta", "Baltimore"], "Baltimore" => ["Washington"], "Atlanta" => ["Washington"]}

  end

end
