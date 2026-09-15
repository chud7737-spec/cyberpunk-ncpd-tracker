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
    valid_types = {"assault_in_progress", "suspected_organized_crime", "reported_crime", "cyberpsycho_sighting", "hidden_gem"}

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

        verified = entry.get('verified', False)
        sources = entry.get('sources', [])

        if verified:
            if not sources:
                print(f"Error: Verified entry {eid} is missing sources.")
                errors += 1
            if "Game resources" in sources and len(sources) == 1:
                print(f"Error: Entry {eid} has vague source 'Game resources'. Must be specific.")
                errors += 1

        pos = entry.get('position')
        if pos:
            if 'x' not in pos or 'y' not in pos or 'z' not in pos:
                print(f"Error: Invalid position format for {eid}")
                errors += 1
            if not sources:
                print(f"Error: Position defined for {eid} but no sources provided.")
                errors += 1

        res = entry.get('resource_path')
        if res and not sources:
            print(f"Error: Resource path defined for {eid} but no sources provided.")
            errors += 1

    print(f"Validation complete. Checked {len(data)} entries. {errors} errors found.")
    return errors == 0

if __name__ == "__main__":
    validate()
