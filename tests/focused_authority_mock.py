"""Production store/mileage authority mocks. No FXServer or database is simulated faithfully."""
from pathlib import Path
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[2]
lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().read_source = lambda product, file: (root / product / file).read_text(encoding="utf-8-sig")
lua.execute(Path(__file__).with_name("focused_authority_spec.lua").read_text(encoding="utf-8"))
assert (root / "zloma_garages/server/vehicle/store_authority.lua").read_bytes() == (
    root / "zloma_simplegarages/server/vehicle/store_authority.lua"
).read_bytes(), "Both garage store authority implementations must match"
