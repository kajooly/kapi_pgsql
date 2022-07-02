# Copyright 2022 Rolando Lucio

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule Builder do

  def match?(string) do
    #  ~r/^(.+; )?(#{@matched_string})/ |> Regex.match?(string)
    String.contains?(string, ".rollback.pgsql")
  end

  @doc """
  Get all *.pgsql files in the current directory and then
  map it to a list of files. with the path and the basename.
  """
  def get_files do
    Path.wildcard("./src/**/*.pgsql")
    |> Enum.map( fn k ->
      basename = Path.basename(k)
      %{ path: k, name: basename, rollback: match?(basename) }
    end)
  end

  def build(inputs, output) do
    File.write( output, "-- Generated by Builder\n\n" )
    inputs
    |> Enum.map(fn(r) ->
      IO.puts r[:path]
      File.write(output, "\n\n -------------------- \n -- #{r[:path]} \n -------------------- \n\n", [:append])
      case File.read(r[:path]) do
        {:ok, content} ->  File.write(output, content, [:append])
        {:error, reason} ->  IO.puts(reason)
      end
    end)
  end

  def run do
    IO.puts "Fetching..."
    files = get_files()
    rollback_files = files |> Enum.sort_by(fn(r) -> r[:name] end, :desc) |> Enum.filter(fn(r) -> r[:rollback] end)
    regular_files = files |> Enum.sort_by(fn(r) -> r[:name] end, :asc) |> Enum.filter(fn(r) -> !r[:rollback] end)
    # IO.inspect files
    IO.puts "Building Regular Files..."
    # IO.inspect regular_files
    build(regular_files, "./build/kapi.install.pgsql")
    IO.puts "Building Rollback Files..."
    # IO.inspect rollback_files
    build(rollback_files, "./build/kapi.rollback.pgsql")
    IO.puts "Done!"
  end

end

Builder.run
