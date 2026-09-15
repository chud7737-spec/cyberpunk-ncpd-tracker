import json
import os

def validate():
    print("Validating NCPD database...")
    db_path = 'data/ncpd.json'
    if not os.path.exists(db_path):
        print(f"Error: {db_path} not found.")
        return False

    with open(db_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    ids = set()
    errors = 0
    valid_types = {"assault_in_progress", "suspected_organized_crime", "reported_crime"}

    for entry in data:
        eid = entry.get('id')
        if not eid:
            print("Error: Missing ID")
            errors += 1
            continue

        if eid in ids:
            print(f"Error: Duplicate ID {eid}")
            errors += 1

        ids.add(eid)

        etype = entry.get('type')
        if etype not in valid_types:
            print(f"Error: Invalid type {etype} for ID {eid}")
            errors += 1

        pos = entry.get('position')
        if not pos and entry.get('verified'):
            print(f"Error: Verified entry missing position {eid}")
            errors += 1

        if pos:
            if 'x' not in pos or 'y' not in pos or 'z' not in pos:
                print(f"Error: Invalid position format for {eid}")
                errors += 1

        if not entry.get('fact_name'):
            print(f"Warning: No fact_name for {eid}. We might not be able to track completion.")

    print(f"Validation complete. Checked {len(data)} entries. {errors} errors found.")
    return errors == 0

if __name__ == "__main__":
    validate()
