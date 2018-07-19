defmodule ConfigTest do
  use ElixirBench.DataCase
  alias ElixirBench.Benchmarks.Config

  describe "changeset/2" do
    test "return config with default values if no input attrs is given" do
      elixir_version = Confex.fetch_env!(:elixir_bench, :default_elixir_version)
      erlang_version = Confex.fetch_env!(:elixir_bench, :default_erlang_version)

      changeset = Config.changeset(%Config{}, %{})

      assert %Config{
               elixir: ^elixir_version,
               erlang: ^erlang_version,
               environment: %{},
               deps: nil
             } = changeset.data

      assert changeset.valid?
    end

    test "return unsupported versions error if elixir and erlang are not supported" do
      supported_elixir = Confex.fetch_env!(:elixir_bench, :supported_elixir_versions)
      supported_erlang = Confex.fetch_env!(:elixir_bench, :supported_erlang_versions)

      refute "99" in supported_elixir
      refute "99" in supported_erlang

      changeset = Config.changeset(%Config{}, %{elixir: "99", erlang: "99"})
      refute changeset.valid?

      assert %{elixir: ["elixir version not supported"], erlang: ["erlang version not supported"]} =
               errors_on(changeset)

      supported_elixir = hd(supported_elixir)
      supported_erlang = hd(supported_erlang)

      changeset =
        Config.changeset(%Config{}, %{elixir: supported_elixir, erlang: supported_erlang})

      assert changeset.valid?
    end

    test "return config given valid docker deps attrs" do
      docker_deps = [
        %{
          image: "postgres:latest",
          environment: %{password: "root"},
          container_name: "pg",
          wait: %{port: 5432}
        },
        %{
          image: "mysql:latest",
          container_name: "mysql",
          wait: %{port: 3306}
        }
      ]

      changeset = Config.changeset(%Config{}, %{deps: %{docker: docker_deps}})

      assert changeset.valid?

      changeset = Ecto.Changeset.apply_changes(changeset)

      assert %{
               deps: %{
                 docker: [
                   %{
                     image: "postgres:latest",
                     environment: %{password: "root"},
                     container_name: "pg",
                     wait: %{port: 5432}
                   },
                   %{
                     image: "mysql:latest",
                     container_name: "mysql",
                     wait: %{port: 3306}
                   }
                 ]
               }
             } = changeset
    end

    test "allow empty docker deps in config" do
      changeset = Config.changeset(%Config{}, %{deps: %{}})
      assert changeset.valid?
      assert %Config{deps: nil} = changeset.data

      changeset = Config.changeset(%Config{}, %{deps: %{docker: []}})
      assert changeset.valid?
      assert %Config{deps: nil} = changeset.data

      changeset = Config.changeset(%Config{}, %{deps: %{docker: %{}}})
      assert changeset.valid?
      assert %Config{deps: nil} = changeset.data
    end

    test "return error given invalid docker deps fields" do
      docker_deps = [%{some_field: "some value"}]
      changeset = Config.changeset(%Config{}, %{deps: %{docker: docker_deps}})

      refute changeset.valid?
      assert %{deps: %{docker: [%{wait: ["can't be blank"]}]}} = errors_on(changeset)
      assert %{deps: %{docker: [%{image: ["can't be blank"]}]}} = errors_on(changeset)

      docker_deps = [%{image: 1, wait: 1}]
      changeset = Config.changeset(%Config{}, %{deps: %{docker: docker_deps}})

      refute changeset.valid?
      assert %{deps: %{docker: [%{wait: ["is invalid"]}]}} = errors_on(changeset)
      assert %{deps: %{docker: [%{image: ["is invalid"]}]}} = errors_on(changeset)

      docker_deps = [%{image: "pg:latest", wait: %{}}]
      changeset = Config.changeset(%Config{}, %{deps: %{docker: docker_deps}})

      refute changeset.valid?
      assert %{deps: %{docker: [%{wait: %{port: ["can't be blank"]}}]}} = errors_on(changeset)
    end

    test "ignore non docker deps" do
      changeset =
        Config.changeset(%Config{}, %{
          deps: %{some_dep: [%{image: "some_image", wait: %{port: 124}}]}
        })

      assert changeset.valid?
      assert %Config{deps: nil} = changeset.data
    end
  end
end
