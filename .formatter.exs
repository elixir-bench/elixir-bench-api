# Used by "mix format"
[
  inputs: ["mix.exs", "{test}/**/*.{ex,exs}"],
  #inputs: ["mix.exs", "{config,test}/**/*.{ex,exs}"],
  #inputs: ["mix.exs", "{config,test,lib/elixir_bench/benchmarks}/**/*.{ex,exs}"],
  #inputs: ["mix.exs", "{config,test,lib/elixir_bench/benchmarks,lib/elixir_bench/github}/**/*.{ex,exs}"],
  #inputs: ["mix.exs", "{config,test,lib/elixir_bench}/**/*.{ex,exs}"],
  #inputs: ["mix.exs", "{config,test,lib/elixir_bench,lib/elixir_bench_web/controllers}/**/*.{ex,exs}"],
  #inputs: ["mix.exs", "{config,test,lib/elixir_bench,lib/elixir_bench_web/controllers,lib/elixir_bench_web/schema}/**/*.{ex,exs}"],
  #inputs: ["mix.exs", "{config,test,lib/elixir_bench,lib/elixir_bench_web/controllers,lib/elixir_bench_web/schema,lib/elixir_bench_web/views}/**/*.{ex,exs}"],
  #inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    plug: 1,
    plug: 2,
    pipeline: 2,
    scope: 2,
    pipe_through: 1,
    forward: 3,
    socket: 2,
    object: 2,
    field: 2,
    field: 3
  ],
  line_length: 98
]
