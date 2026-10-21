"""Package already-reviewed public output; never include drafts or server config."""
import argparse, hashlib, json, re, zipfile
from pathlib import Path
ALLOWED={'.html','.css','.js','.json','.yml','.png','.jpg','.jpeg','.gif','.svg','.webp','.ico','.pdf','.ttf','.woff','.woff2','.txt'}
def package(source, output, tag, channel, commit):
    if channel not in {'preview','production'}: raise ValueError('Invalid channel')
    prefix='preview-' if channel=='preview' else 'bantin-'
    if not tag.startswith(prefix) or not re.fullmatch(r'[a-zA-Z0-9.-]+',tag): raise ValueError('Invalid release tag')
    if not re.fullmatch(r'[a-f0-9]{40}',commit): raise ValueError('Invalid commit')
    if not (source/'index.html').is_file(): raise ValueError('Missing index.html')
    output.mkdir(parents=True,exist_ok=True)
    files=[]
    with zipfile.ZipFile(output/'bantin-site.zip','w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(source.rglob('*')):
            if p.is_symlink(): raise ValueError('Symlink blocked')
            if not p.is_file(): continue
            if p.name == '.gitkeep' or re.fullmatch(r'chart[1-5]-source\.xml',p.name): continue
            name=p.relative_to(source).as_posix()
            if name == 'web.config' or name.startswith(('admin/','ban-tin-moi/','oauth/')): continue
            if not re.fullmatch(r'[a-zA-Z0-9_./-]+',name) or any(x in {'.','..'} for x in name.split('/')) or p.suffix.lower() not in ALLOWED:
                raise ValueError(f'Blocked path: {name}')
            data=p.read_bytes()
            files.append({'path':name,'sha256':hashlib.sha256(data).hexdigest()})
            z.writestr(name,data)
    meta={'schema':2,'channel':channel,'commit':commit,'tag':tag,'zip_sha256':hashlib.sha256((output/'bantin-site.zip').read_bytes()).hexdigest(),'files':files}
    (output/'release.json').write_text(json.dumps(meta,indent=2),encoding='utf-8')
    print(f'Packaged {len(files)} files')
if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('--source',type=Path,default=Path('public'));a.add_argument('--output',type=Path,default=Path('release-output'));a.add_argument('--tag',required=True);a.add_argument('--channel',required=True,choices=['preview','production']);a.add_argument('--commit',required=True)
    v=a.parse_args();package(v.source,v.output,v.tag,v.channel,v.commit)
