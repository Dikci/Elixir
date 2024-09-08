docker stop elixir-node
docker rm elixir-node
docker stop elixir
docker rm elixir
docker rmi -f elixir-validator &>/dev/null
docker rm -f ev &>/dev/null
docker pull elixirprotocol/validator:v3
cd elixir
docker run -it --env-file ./Dockerfile --name elixir-node --restart unless-stopped -p 17690:17690 elixirprotocol/validator:v3
