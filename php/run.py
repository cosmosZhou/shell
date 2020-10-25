import sys
import os
import re

conf = get_conf_file()
    
def get_conf_file():
    pwd = os.path.dirname(__file__)
    pwd = os.path.dirname(pwd)
    pwd = os.path.dirname(pwd)
    conf = pwd + '/httpd/conf/httpd.conf'
    print('conf =', conf)
    return conf

def subs_dir_module():
     
# <IfModule dir_module>
#     DirectoryIndex index.php index.html
# </IfModule>

    lines, num = scan_conf("<IfModule dir_module>")
    lines[num + 1] = "    DirectoryIndex index.php index.html"
    write_conf(lines)
    
def scan_conf(regex):
    num = -1    
    with open(conf, 'r') as file:
        lines = [*file]
        
    for i, line in enumerate(lines):             
        if re.compile(regex).match(line):
            print(line)
            num = i
            break
    return lines, num
        
def subs_port(port):
    lines, numListen = scan_conf("^Listen")    
    lines, posServerName = scan_conf("^ServerName localhost:\d+")
    
    if posServerName < 0:
        lines, posServerName = scan_conf("^#ServerName \S+:\d+")
        assert posServerName >= 0
        
    lines[numListen] = "Listen " + port
    lines[posServerName] = "ServerName localhost: " + port
    write_conf(lines)
    
    
def subs_document_root(DocumentRoot):    
    print('DocumentRoot =', DocumentRoot)
    
    lines, num = scan_conf("^DocumentRoot")
    lines[num] = 'DocumentRoot "%s"\n' % DocumentRoot
    lines[num + 1] = '<Directory "%s">\n' % DocumentRoot
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
#             if line.strip():
            lines.append(line)
    lines.append(pycache_settings)
    write_conf(lines)
    
if __name__ == '__main__':
    cmd, *args = sys.argv[1:]
    eval(cmd)(*args)
