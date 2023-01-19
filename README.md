# Protohacker

<a href="https://github.com/derhackler/protohacker/actions"><img src="https://github.com/derhackler/protohacker/actions/workflows/elixir.yml/badge.svg?branch=main" alt="build and test badge"></a>

Implementation of the [Protohackers](https://protohackers.com) challenges



## Setup dev environment

  - install elixir 1.14
  - install docker

## Try Locally

The server will listen on port 5555

run `iex -S mix` to start the server locally

run `telnet 127.0.0 5555` to test via telnet

## Publish to Stackpath

### build image and publish to docker registry

```bash
docker build -t derhackler/protohack:0.3.0 .
docker push derhackler/protohack:0.3.0
```

### deploy to stackpath prerequisite

1. Register an account on stackpath.com
2. Create a new stack called 'protohack'
3. Create an API Token in the UI
4. Set your environment variables:

```bash
export STACKPATH_CID=[YOUR_CLIENT_ID]
export STACKPATH_CS=[YOUR_CLIENT_SECRET]
```

5. Compile the project `mix compile`

### deploy

6. run `mix my.deploy derhackler/protohack:0.3.0`
7. copy the ip address from the ui

### cleanup

delete the workload via the stackpath ui