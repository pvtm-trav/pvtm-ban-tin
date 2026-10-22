"""Allow a production release only for an isolated draft -> published approval."""
import json
import os
import pathlib
import re
import subprocess


def git(*args):
    return subprocess.check_output(['git', *args], text=True).strip()


def main():
    sha = os.environ['APPROVED_SHA']
    if not re.fullmatch(r'[a-f0-9]{40}', sha):
        raise ValueError('Invalid approved SHA')
    parent = git('rev-parse', sha + '^')
    paths = git('diff', '--name-only', parent, sha).splitlines()
    modified = set(git('diff', '--name-only', '--diff-filter=M', parent, sha).splitlines())
    candidates = []
    for changed in paths:
        if changed not in modified or not re.fullmatch(r'content/issues/so-[0-9]+-[0-9]{4}\.json', changed):
            continue
        before_issue = json.loads(git('show', parent + ':' + changed))
        after_issue = json.loads(pathlib.Path(changed).read_text(encoding='utf-8'))
        if before_issue.get('status') == 'draft' and after_issue.get('status') == 'published':
            candidates.append(changed)
    if not candidates:
        print('No draft-to-published approval in this commit; no production release.')
        return
    if len(paths) != 1 or len(candidates) != 1:
        raise ValueError('Approval commit must change exactly one issue file')
    path = paths[0]
    before = json.loads(git('show', parent + ':' + path))
    after = json.loads(pathlib.Path(path).read_text(encoding='utf-8'))
    if before.get('status') != 'draft' or after.get('status') != 'published':
        raise ValueError('Approval must change draft to published')
    if {**before, 'status': 'published'} != after:
        raise ValueError('Approval commit changed issue content; review a fresh preview')
    if after.get('id') + '.json' != pathlib.Path(path).name:
        raise ValueError('Issue ID does not match its file')
    if not isinstance(after.get('number'), int) or not isinstance(after.get('year'), int):
        raise ValueError('Issue number or year is invalid')
    tag = f'bantin-{after["year"]}.{after["number"]}-{sha[:12]}'
    with open(os.environ['GITHUB_ENV'], 'a', encoding='utf-8') as env:
        env.write(f'APPROVAL_PRESENT=true\nRELEASE_TAG={tag}\nISSUE_ID={after["id"]}\nPREVIEW_PARENT={parent}\n')
    print(f'Approved {after["id"]}: preview parent {parent}, production {sha}')


if __name__ == '__main__':
    main()
