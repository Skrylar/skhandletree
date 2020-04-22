
def task_build():
    return {
    	'actions': ['nim c skhandletree'],
    	'targets': ['skhandletree'],
    	'file_dep': ['skhandletree.nim']
    }

def task_check():
    return {
    	'task_dep': ['build'],
    	'actions': ['timeout 5 ./skhandletree'],
    	'verbosity': 2,
    }
