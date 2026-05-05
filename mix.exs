defmodule AshToonEx.MixProject do
  use Mix.Project

  @name :ash_toon_ex
  @version "0.2.0"
  @description "Ash extension for implementing ToonEx.Encoder protocol"
  @github_url "https://github.com/ohhi-vn/ash_toon_ex"

  def project do
    [
      app: @name,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      package: package(),
      deps: deps(),
      docs: &docs/0,
      aliases: aliases(),
      test_coverage: [ignore_modules: [AshToonEx.ExtensionHelpers]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
    ]
  end

  defp package() do
    [
      maintainers: ["Manh Vu"],
      description: @description,
      licenses: ["MIT"],
      links: %{Github: @github_url},
      files: ~w(mix.exs lib .formatter.exs LICENSE.md  README.md),
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ash, ash_version("~> 3.24")},
      {:spark, "~> 2.7"},
      {:igniter, "~> 0.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sourceror, "~> 1.7", only: [:dev, :test], runtime: false},
      {:freedom_formatter, "~> 2.1", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.16.0", only: [:dev, :test], runtime: false},
      {:toon_ex, "~> 1.1"},
      # Test dependencies
      {:excoveralls, "~> 0.18", only: :test},
    ]
  end

  def docs() do
    [
      homepage_url: @github_url,
      source_url: @github_url,
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md": [title: "Guide"],
        "LICENSE.md": [title: "License"],
        "documentation/dsls/DSL-AshToonEx.Resource.md": [
          title: "DSL: AshToonEx.Resource",
          search_data: Spark.Docs.search_data_for(AshToonEx.Resource),
        ],
        "documentation/dsls/DSL-AshToonEx.TypedStruct.md": [
          title: "DSL: AshToonEx.TypedStruct",
          search_data: Spark.Docs.search_data_for(AshToonEx.TypedStruct),
        ],
      ],
    ]
  end

  defp ash_version(default_version) do
    case System.get_env("ASH_VERSION") do
      nil -> default_version
      "local" -> [path: "../ash"]
      "main" -> [git: "https://github.com/ash-project/ash.git"]
      version -> "~> #{version}"
    end
  end

  defp aliases() do
    [
      docs: ["spark.cheat_sheets", "docs", "spark.replace_doc_links"],
      "spark.cheat_sheets": "spark.cheat_sheets --extensions AshToonEx.Resource,AshToonEx.TypedStruct",
      "spark.formatter": [
        "spark.formatter --extensions AshToonEx.Resource,AshToonEx.TypedStruct",
        "format .formatter.exs",
      ],
    ]
  end
end
