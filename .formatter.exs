# Used by "mix format"
[
  inputs: ["mix.exs", "lib/elixir_bench/{benchmarks,github}/**/*.{ex,exs}", "{config,test}/**/*.{ex,exs}"],
  #inputs: ["mix.exs", "lib/elixir_bench/**/*.{ex,exs}", "{config,test}/**/*.{ex,exs}"],
  #inputs: ["mix.exs","lib/elixir_bench_web/**/*.{ex,exs}", "lib/elixir_bench/**/*.{ex,exs}", "{config,test}/**/*.{ex,exs}"],
  #inputs: ["mix.exs","{config,test,lib}/**/*.{ex,exs}"],
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
