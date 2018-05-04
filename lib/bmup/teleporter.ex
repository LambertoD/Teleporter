defmodule Bmup.Teleporter do

  def add_route(key, value, current_routes) do
    route1 = map_adder(%{}, key, [value])
    route2 = map_adder(%{}, value, [key])

    Map.merge(route1, route2, &map_merger/3)
    |> Map.merge(current_routes, &map_merger/3)

  end

  defp map_merger(_k, v1, v2) do
    [v1, v2] |> Enum.concat
  end

  defp map_adder(map, key, value) do
    Map.put(map, key, value)
  end
end
