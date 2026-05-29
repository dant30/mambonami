import sys, os, pathlib
print('cwd=', os.getcwd())
print('sys.path[0:5]=')
for p in sys.path[:10]:
    print('  ', p)
root = pathlib.Path(__file__).resolve().parents[2]
dj_dir = pathlib.Path(__file__).resolve().parents[1]
print('workspace_root=', root)
print('django_admin_dir=', dj_dir)
print('shared exists under workspace root?', (root / 'shared').is_dir())
print('shared path =', str(root / 'shared'))
print('listing shared:', os.listdir(str(root / 'shared'))[:20])
