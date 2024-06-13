# Convert json payload to procedure call with json string as an argument
# argv[1] should be a procedure name
import sys

if len(sys.argv) < 2:
    print("Missing procedure name (argv[1])", file=sys.stderr)
    exit(1)

procedure_name = sys.argv[1]

print(f"call {procedure_name}('", end="")

for line in sys.stdin:
    line = line.strip()
    print(line.replace("'", "''"), end="")

print(f"'::json);", end="")
