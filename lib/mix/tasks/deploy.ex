defmodule Mix.Tasks.My.Deploy do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task

  @headers [accept: "application/json", content_type: "application/json"]

  @shortdoc "Deploys to stackblitz. First parameter is the image name to pull from dockerhub."
  def run(args) do
    Application.ensure_all_started(:req)

    image = hd(args)

    token = get_bearer()

    stack =
      stacks(token)
      |> Enum.find(fn %{"name" => name} -> "protohack" == name end)
      |> get_in(["slug"])

    create_workload(token, stack, image) |> IO.inspect()
  end

  defp stacks(token) do
    req = Req.new(base_url: "https://gateway.stackpath.com")

    Req.get!(req, url: "/stack/v1/stacks", headers: @headers, auth: {:bearer, token}).body[
      "results"
    ]
  end

  defp create_workload(token, stack, image) do
    request = %{
      "workload" => %{
        "name" => "protohack",
        "slug" => "protohack",
        "spec" => %{
          "containers" =>%{
              "container-0" => %{
                "image" => image,
                "resources" => %{
                  "requests" => %{"cpu" => 1, "memory" => "2Gi"},
                },
                "ports" => %{"port0" => %{
                  "port" => 5555,
                  "enableImplicitNetworkPolicy" => true,
                  "protocol" => "TCP"
                }}
              }
            },
          "networkInterfaces" => [
            %{"enableOneToOneNat" => true, "network" => "default"}
          ]
        },
        "stackId" => stack,
        "targets" =>
          %{
            "eu" =>
             %{
              "spec" => %{
                "deploymentScope" => "cityCode",
                "deployments" => %{
                  "minReplicas" => 1,
                  "selectors" => [
                    %{
                      "key" => "cityCode",
                      "operator" => "in",
                      "values" => ["FRA"]
                    }
                  ]
                }
              }
            }
          }
      }
    }

    req = Req.new(base_url: "https://gateway.stackpath.com")

    headers = [
      accept: "application/json",
      content_type: "application/json"
    ]

    Req.post!(req,
      url: "/workload/v1/stacks/#{stack}/workloads",
      json: request,
      headers: headers,
      auth: {:bearer, token}
    ).body
  end

  defp get_bearer() do
    req = Req.new(base_url: "https://gateway.stackpath.com")

    data = %{
      client_id: System.get_env("STACKPATH_CID"),
      client_secret: System.get_env("STACKPATH_CS"),
      grant_type: "client_credentials"
    }

    headers = [
      accept: "application/json",
      content_type: "application/json"
    ]

    Req.post!(req, url: "/identity/v1/oauth2/token", json: data, headers: headers).body[
      "access_token"
    ]
  end
end
