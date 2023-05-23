import sys
MPM = f'{sys.version_info.major}.{sys.version_info.minor}'
MM = f'{sys.version_info.major}{sys.version_info.minor}'
print(f'LoadModule wsgi_module "/usr/local/lib/python{MPM}/dist-packages/mod_wsgi/server/mod_wsgi-py{MM}.cpython-{MM}-x86_64-linux-gnu.so"')

