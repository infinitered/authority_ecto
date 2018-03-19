defmodule Authority.Ecto.MixProject do
  use Mix.Project

  def project do
    [
      app: :authority_ecto,
      description: "Implements Authority behaviours using Ecto for persistence",
      version: "0.1.2",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp package do
    [
      maintainers: ["Daniel Berkompas"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/infinitered/authority_ecto",
        "Authority (GitHub)" => "https://github.com/infinitered/authority",
        "Authority (Hex)" => "https://hex.pm/authority"
      },
      source_url: "https://github.com/infinitered/authority_ecto"
    ]
  end

  defp docs do
    [
      main: Authority.Ecto,
      groups_for_modules: [
        Implementation: [
          Authority.Ecto.Template
        ],
        Changesets: [
          Authority.Ecto.Changeset,
          Authority.Ecto.HMAC
        ]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:authority, "~> 0.3"},
      {:ecto, ">= 0.0.0"},
      {:comeonin, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
      {:exnumerator, ">= 0.0.0", only: [:dev, :test]},
      {:bcrypt_elixir, ">= 0.0.0", only: [:dev, :test]},
      {:argon2_elixir, ">= 0.0.0", only: [:dev, :test]},
      {:pbkdf2_elixir, ">= 0.0.0", only: [:dev, :test]},
      {:postgrex, ">= 0.0.0", only: [:test]},
      {:phoenix, ">= 0.0.0", only: [:test]}
    ]
  end

  defp aliases do
    [test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]]
  end
end
