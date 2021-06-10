import sys
import math
import os

text = sys.argv[1]
nj = int(sys.argv[2])
out_dir = sys.argv[3]

os.makedirs(out_dir, exist_ok=True)

with open(text) as f:
    lines = list(f.readlines())

step_size = math.ceil(len(lines) / nj)

for i in range(nj):
    with open(os.path.join(out_dir, f'text.{i + 1}'), 'w') as of:
        offset = i * step_size
        of.writelines(lines[offset:offset + step_size])

