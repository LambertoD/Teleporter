defmodule Bmup.Teleporter do

  def add_route(port_system, key, value ) do

    route1 = map_adder(%{}, key, [value])
    route2 = map_adder(%{}, value, [key])
    cities_in_system = [key, value] |> Enum.sort
    port_routes = cities_in_system |> check_lines(port_system)

    Map.merge(route1, route2, &map_merger/3)
    |> Map.merge(port_system, &map_merger/3)
    |> add_cities(cities_in_system)
    |> add_port_routes(port_routes)
  end

  def check_lines(city_list, routes) do
    if Map.has_key?(routes, "port_routes") do
      update_port_routes(routes["port_routes"], city_list)
    else
      %{"1" => city_list}
    end
  end

  @doc """
    Check all existing port_routes and re-create as necessary as
    new connections are made between cities.
    If cities in city_list are not found in existing port_routes then
    a new port_route is created for that city_list.
    If cities in city_list are found in existing port_routes then
    the port_route is updated to include cities in city_list.
    If cities in city_list are found separately in other port_routes then
    the 2 port_routes are merged into 1 port_route.

    [["Atlanta", "Washington"], ["Baltimore", "Philadelphia"]]
    into
    %{"1" => ["Atlanta", "Washington"],
      "2" => ["Baltimore", "Philadelphia"]}
    OR
    [["Atlanta", "Washington"], ["Baltimore", "Philadelphia"]]
      with city_list ["Washington", "Baltimore"]
    into
    %{"1" => ["Atlanta", "Baltimore", " "Washington", "Philadelphia"],
  """
  def update_port_routes(port_routes, city_list) do
    # mark current routes that have common members with city list
    marked_routes =
      Enum.map(port_routes, fn {k,v} -> cities_in_current_port_routes({k,v}, city_list) end)



    # use reduce to make lines,  use MapSet as function helper
    lines
    |> Map.values
    |> Enum.reduce(%{}, fn(x, line_map) -> recreate_lines(x, city_list, line_map) end )
  end

  def recreate_lines(route_line, cities, lines) do
    if MapSet.disjoint?(MapSet.new(route_line), MapSet.new(cities)) do
      if Enum.empty? lines do
        Map.put_new(lines, "1", route_line)
        |> Map.put_new("2", cities)
      else
       last_key = Map.keys(lines) |> List.last
       new_key = (String.to_integer(last_key) + 1) |> Integer.to_string
       Map.put_new(lines, new_key, route_line)
      end
    else
      if Enum.empty? lines do
       new_line =
        MapSet.union(MapSet.new(route_line), MapSet.new(cities))
        |> MapSet.to_list
       Map.put_new(lines, "1", new_line)
      else
        current_routes = Map.values(lines) |> List.flatten
         new_line =
          MapSet.union(MapSet.new(current_routes), MapSet.new(route_line))
          |> MapSet.to_list
         %{ lines | "1" => new_line}
      end
    end
  end

  def cities_in_current_port_routes({key, value}, city_list) do
    if MapSet.disjoint?(MapSet.new(value.route_path), MapSet.new(city_list)) do
      updated_route = Map.new([{:route_path, value.route_path}, {:status, :match}]) 
      Map.new([{key, updated_route}])
    else
      Map.new([{key, value}])
    end
  end

  def add_cities(port_system, cities) do
    if Map.has_key?(port_system, "cities_in_system") do
      updated_cities = 
        MapSet.put(MapSet.new(port_system["cities_in_system"]), cities)
        |> MapSet.to_list |> List.flatten |> Enum.sort

      %{port_system | "cities_in_system" => updated_cities}
    else
      Map.put(port_system, "cities_in_system", cities)
    end
  end

  def add_port_routes(routes, port_routes) do
    if Map.has_key?(routes, "port_routes") do
      %{routes | "port_routes" => port_routes}
    else
      Map.put(routes, "port_routes", port_routes)
    end
  end

  def teleport_options_with_jump_count(routes, city, number) do
    case number do
      1 -> routes[city]
      2 -> get_hops(routes, city)
      _ -> get_hops(routes, city, [])
    end
  end

  def get_hops(routes, city) do
    next_hops =
      routes[city] |> Enum.map(fn hop -> routes[hop] end)

    merge_hops(routes, city, next_hops)
  end

  def get_hops(routes, city, current_hops) do
    [ get_hops(routes, city) | current_hops]
  end

  def merge_hops(routes, city, next_hops) do
    all_hops = routes[city] ++ next_hops
    List.flatten(all_hops)
    |> Enum.uniq
    |> (Kernel.-- [city])
  end

  def can_beam_to_city?(routes, current_city, desired_city) do
    # search routes =>  recurse through get_hops until end
    # build route path
    # Enum.member?(full_route, desired_city)
    true
  end

  defp map_merger(_k, v1, v2) do
    [v1, v2] |> Enum.concat
  end

  defp map_adder(map, key, value) do
    Map.put(map, key, value)
  end
end
