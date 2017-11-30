defmodule WechatMp.Mixfile do
  use Mix.Project

  @version "0.0.3"

  def project do
    [app: :wechat_mp_auth,
     version: @version,
     package: package(),
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/he9qi/wechat_mp_auth",
     homepage_url: "https://github.com/he9qi/wechat_mp_auth",
     description: description(),
     deps: deps(),
     docs: docs(),
     elixirc_paths: elixirc_paths(Mix.env),
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:cowboy, :logger, :plug, :httpoison, :redix, :con_cache],
     mod: {WechatMPAuth, []}]
  end

  defp deps do
    [{:cowboy, "~> 1.1.2"},
     {:httpoison, "~> 0.13"},
     {:plug, "~> 1.0"},
     {:poison, "~> 2.2 or ~> 3.0"},
     {:mimetype_parser, "~> 0.1"},
     {:redix, "0.4.0"},

     {:bypass, "~> 0.1", only: :test},
     {:excoveralls, "~> 0.3", only: :test},
     {:con_cache, "~> 0.12.0"},

     # docs dependencies
     {:earmark, "~>0.1", only: :dev},
     {:ex_doc, "~>0.1", only: :dev}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [extras: ["README.md"], main: "readme"]
  end

  defp description do
    "An Elixir WeChat Media Platform Authentication Client Library."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Qi He"],
      licenses: ["MIT"],
      links: %{"Github": "https://github.com/he9qi/wechat_mp_auth"}]
  end
end
