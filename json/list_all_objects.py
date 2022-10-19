"""
This file is meant to print all JSONs in this directory
in a list so that we can create a Postman command that 
updates all objects in the Orion broker.
"""

import json
import glob

# PyPI imports

# Custom imports


def main():
    jsons = glob.glob("*.json")
    objects = []
    for json_ in jsons:
        print(f"Processing {json_}")
        with open(json_, "r") as f:
            obj = json.load(f)
        objects.append(obj)
    print(
        str(objects)
        .replace("'", '"')
        .replace("True", "true")
        .replace("False", "false")
        .replace("None", "null")
    )


if __name__ == "__main__":
    main()
