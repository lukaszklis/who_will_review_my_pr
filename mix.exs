defmodule WhoWillReviewMyPr.Mixfile do
  use Mix.Project

  def project do
    [ app: :who_will_review_my_pr,
      version: "0.0.1",
      dynamos: [WhoWillReviewMyPr.Dynamo],
      compilers: [:elixir, :dynamo, :app],
      env: [prod: [compile_path: "ebin"]],
      compile_path: "tmp/#{Mix.env}/who_will_review_my_pr/ebin",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:cowboy, :dynamo],
      mod: { WhoWillReviewMyPr, [] } ]
  end

  defp deps do
    [
      { :cowboy, github: "extend/cowboy" },
      { :dynamo, "0.1.0-dev", github: "elixir-lang/dynamo" },
      { :json, github: "cblage/elixir-json"}
    ]
  end
end
