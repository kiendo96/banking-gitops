import sys
import os

def scrub_yaml(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()
    out = []
    skip_indent = -1
    for line in lines:
        stripped = line.lstrip()
        indent = len(line) - len(stripped)
        
        # If we are currently skipping lines due to a parent block being deleted
        if skip_indent != -1:
            if stripped == '' or indent > skip_indent:
                continue  # skip children lines
            else:
                skip_indent = -1  # back to sibling or higher level, stop skipping
                
        # Start skipping when we hit x-kubernetes-validations
        if stripped.startswith('x-kubernetes-validations:'):
            skip_indent = indent
            continue
            
        out.append(line)
        
    with open(filepath, 'w') as f:
        f.writelines(out)

if __name__ == '__main__':
    crds_dir = sys.argv[1]
    for filename in os.listdir(crds_dir):
        if filename.endswith(".yaml"):
            scrub_yaml(os.path.join(crds_dir, filename))
