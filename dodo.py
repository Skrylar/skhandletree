
def task_build():
    return {
    	'actions': ['nim c skhandletree'],
    	'targets': ['skhandletree'],
    	'file_dep': ['skhandletree.nim']
    }

def task_check():
    return {
    	'task_dep': ['build'],
    	'actions': [
            'timeout 5 ./skhandletree | tee dump.dot',
            'gvpack -u dump.dot > packed.dot',
            'dot -Tpng packed.dot > dump.png'],
    	'verbosity': 2,
    }
