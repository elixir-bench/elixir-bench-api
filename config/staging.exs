use Mix.Config

# Any custom change to be tested in a production like environment must be added here
import_config "prod.exs"

config :elixir_bench, ElixirBenchWeb.Endpoint, origins: [~r/tallysmartins.github.io$/]
