count = 1
with open('inventory.ini', 'r') as infile, open('temp.ini', 'w') as outfile:
    for line in infile:
        if 'etcd_member_name=etcd' in line:
            outfile.write(f'{line.strip()}{count}\n')
            count += 1
        else:
            outfile.write(line)

import os
os.rename('temp.ini', 'inventory.ini')