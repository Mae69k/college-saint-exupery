import sys
paths = ['style.css','index.html']
for p in paths:
    try:
        with open(p, encoding='utf-8', errors='ignore') as f:
            t = f.read()
        t = t.replace(\"'Inter'\", 'Arial').replace(\"'Fraunces'\", 'Arial')
        with open(p, 'w', encoding='utf-8') as f:
            f.write(t)
    except:
        pass
print('ok')
