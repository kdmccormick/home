
ENV = "prod"

def load(set_name):
    with open(f"{ENV}_{set_name}.list", "r") as f:
        return set(f.read().splitlines())

def dump(set_name, the_set):
    with open(f"{ENV}_{set_name}.list", "w") as f:
        f.write("\n".join(sorted(the_set)) + "\n")
