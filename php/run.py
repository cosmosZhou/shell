import sys
import os
import re

pwd = os.path.dirname(__file__)
pwd = os.path.dirname(pwd)
pwd = os.path.dirname(pwd)
conf = pwd + '/httpd/conf/httpd.conf'
print('conf =', conf)

    
def subs_document_root(DocumentRoot):
    
    print('DocumentRoot =', DocumentRoot)
    
    lines = []
    with open(conf, 'r') as file:
        lineBeforeDetected = False
        for line in file:             
            if lineBeforeDetected:
                print(line)
                lineBeforeDetected = False
                line = '<Directory "%s">' % DocumentRoot
                                
            elif re.compile('^DocumentRoot').match(line):
                print(line)
                lineBeforeDetected = True
                line = 'DocumentRoot "%s"' % DocumentRoot
            
            if line.strip():
                lines.append(line)
    write_conf(lines)

def write_conf(lines):
    with open(conf, 'w') as file:
        for line in lines:
            print(line, end='', file=file)
    
def alter_pycache_permission():
    pycache_settings = """\
<Files ~ ".py|.pyc|.gitignore">
    Order allow,deny
    Deny from all
</Files>

<Directory ~ "__pycache__">
    Order allow,deny
    Deny from all
</Directory>
"""
    lines = []
    with open(conf, 'r') as file:
        pycacheDetected = False
        for line in file:             
            if re.compile('<Directory ~ "__pycache__">').match(line):
                return
            if line.strip():
                lines.append(line)
    lines.append(pycache_settings)
    write_conf(lines)
    
if __name__ == '__main__':
    cmd, *args = sys.argv[1:]
    eval(cmd)(*args)
