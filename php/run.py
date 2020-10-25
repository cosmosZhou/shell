import sys
import os
import re
    
def get_conf_file():
    pwd = os.path.dirname(__file__)
    pwd = os.path.dirname(pwd)
    pwd = os.path.dirname(pwd)
    conf = pwd + '/httpd/conf/httpd.conf'
    print('conf =', conf)
    return conf
        
def subs_document_root(DocumentRoot):    
    conf = get_conf_file()
    print('DocumentRoot =', DocumentRoot)
    
    lines = []
    with open(conf, 'r') as file:
        lineBeforeDetected = False
        for line in file:             
            if lineBeforeDetected:
                print(line)
                lineBeforeDetected = False
                line = '<Directory "%s">\n' % DocumentRoot
                                
            elif re.compile('^DocumentRoot').match(line):
                print(line)
                lineBeforeDetected = True
                line = 'DocumentRoot "%s"\n' % DocumentRoot
            
#             if line.strip():
            lines.append(line)
    write_conf(conf, lines)

def write_conf(conf, lines):
    with open(conf, 'w') as file:
        for line in lines:
            print(line, end='', file=file)
    
def alter_pycache_permission():
    conf = get_conf_file()
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
#             if line.strip():
            lines.append(line)
    lines.append(pycache_settings)
    write_conf(conf, lines)
    
if __name__ == '__main__':
    cmd, *args = sys.argv[1:]
    eval(cmd)(*args)
