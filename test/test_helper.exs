# The doctests are the visual regression suite, so running them against a
# backend is how we check that one renders identically to the others. Nothing
# here should be needed to run the suite normally.
#
#     VIVID_BACKEND=exla mix test
#     VIVID_BACKEND=exla VIVID_COMPILER=exla mix test
#     VIVID_BACKEND=torchx mix test

backend =
  case System.get_env("VIVID_BACKEND") do
    empty when empty in [nil, ""] -> nil
    "binary" -> Nx.BinaryBackend
    "exla" -> EXLA.Backend
    "torchx" -> Torchx.Backend
    other -> raise "unknown VIVID_BACKEND #{inspect(other)}"
  end

if backend do
  Code.ensure_loaded!(backend)
  Nx.global_default_backend(backend)
end

case System.get_env("VIVID_COMPILER") do
  empty when empty in [nil, ""] -> :ok
  "exla" -> Nx.Defn.global_default_options(compiler: EXLA)
  other -> raise "unknown VIVID_COMPILER #{inspect(other)}"
end

ExUnit.start()
