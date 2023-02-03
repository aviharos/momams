"""
This file is meant to print all JSONs in this directory
in a list so that we can create a Postman command that 
updates all objects in the Orion broker.
"""

# Standard Library imports
import json
import glob


def main():
    jsons = glob.glob("*.json")
    objects = []
    for json_ in jsons:
        print(f"Processing {json_}")
        with open(json_, "r") as f:
            obj = json.load(f)
        objects.append(obj)
    print(json.dumps(objects))


if __name__ == "__main__":
    main()
