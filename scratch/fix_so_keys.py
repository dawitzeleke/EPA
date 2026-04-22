import io

path = r'c:\Users\lenovo\Documents\AI Institute\EPRS-Clean-Ethiopia-App\eprs\lib\core\constants\languages\app_translations.dart'
with io.open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# find _soLegacy end
so_end_index = -1
for i, line in enumerate(lines):
    if line.strip() == '};' and 'static Future<AppTranslations> load() async {' in lines[i+2]:
        so_end_index = i
        break

# find the misplaced keys in _flattenMap
flattened_start = -1
flattened_end = -1
for i, line in enumerate(lines):
    if 'final flattened = <String, String>{' in line and "'About Us': 'Nagu saabsan'," in line:
        flattened_start = i
        break

if flattened_start != -1:
    for i in range(flattened_start, len(lines)):
        if lines[i].strip() == '};' and 'source.forEach((key, value) {' in lines[i+2]:
            flattened_end = i
            break

if so_end_index != -1 and flattened_start != -1 and flattened_end != -1:
    # extract keys
    # first line is: final flattened = <String, String>{    'About Us': 'Nagu saabsan',
    keys_lines = []
    first_line = lines[flattened_start]
    keys_lines.append(first_line.replace('final flattened = <String, String>{', ''))
    
    for i in range(flattened_start + 1, flattened_end):
        keys_lines.append(lines[i])
        
    # restore flattened map
    lines[flattened_start:flattened_end+1] = ['    final flattened = <String, String>{};\n']
    
    # insert keys into _soLegacy
    # wait, so_end_index might have changed after deletion if so_end_index > flattened_start,
    # but so_end_index is before flattened_start!
    
    lines = lines[:so_end_index] + keys_lines + lines[so_end_index:]
    
    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Fixed Somali keys!")
else:
    print(f"Could not find indices: so_end={so_end_index}, start={flattened_start}, end={flattened_end}")
