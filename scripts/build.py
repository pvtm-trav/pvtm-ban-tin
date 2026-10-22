#!/usr/bin/env python3
"""Deterministic data-driven build: YAML + Markdown -> dist HTML + manifest + SHA256SUMS."""
from __future__ import annotations
import argparse,hashlib,json,re,shutil,subprocess
from pathlib import Path
import yaml
from jinja2 import Environment,FileSystemLoader,select_autoescape
from lxml import html as LH
ROOT=Path(__file__).resolve().parents[1]; DIST=ROOT/'dist'; CATEGORIES=['TIN TRONG NƯỚC','TIN NƯỚC NGOÀI','THÔNG TIN XUẤT NHẬP KHẨU']
def split_md(path):
 text=path.read_text(encoding='utf-8'); m=re.match(r'\A---\s*\n(.*?)\n---\s*\n?(.*)\Z',text,re.S)
 if not m: raise ValueError(f'{path}: thiếu front matter')
 return yaml.safe_load(m.group(1)) or {},m.group(2)
def sha(path):
 h=hashlib.sha256()
 with path.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return h.hexdigest()
def render_body(raw):
 if re.match(r'\s*<',raw): body=raw
 else:
  import markdown; body=markdown.markdown(raw,extensions=['extra','sane_lists'],output_format='html5')
 frag=LH.fragment_fromstring(body or '<p></p>',create_parent='div')
 if frag.xpath('.//script|.//iframe|.//object|.//embed'): raise ValueError('Nội dung chỉ được chứa HTML tĩnh')
 return ''.join(LH.tostring(e,encoding='unicode') for e in frag)
def issue_model(path):
 issue=yaml.safe_load(path.read_text(encoding='utf-8')); articles=[]; by_short={}
 for section in issue['sections']:
  for short in section['articles']:
   meta,raw=split_md(ROOT/'content'/'articles'/issue['id']/f'{short}.md')
   if not raw.strip() and meta.get('legacy_source'): raw=json.loads((ROOT/meta['legacy_source']).read_text(encoding='utf-8')).get('body_html','')
   a={**meta,'short_id':short,'html':render_body(raw),'anchor':f'article-{len(articles)+1}'}; articles.append(a); by_short[short]=a
 cover=issue['cover']; heads=cover['headline_articles']; images=cover['feature_images']
 compat={**issue,'hero':cover['hero'],'hero_top_mm':cover.get('hero_top_mm',-76.3),'headline1':by_short[heads[0]]['title'],'headline2':by_short[heads[1]]['title'],'image1':images[0],'image2':images[1]}
 groups=[{'name':name,'articles':[a for a in articles if a['category']==name]} for name in CATEGORIES]; return compat,articles,groups
def write_manifest(issue_ids):
 files=[]
 for p in sorted(x for x in DIST.rglob('*') if x.is_file() and x.name not in ('manifest.json','SHA256SUMS')): files.append({'path':p.relative_to(DIST).as_posix(),'size':p.stat().st_size,'sha256':sha(p)})
 (DIST/'manifest.json').write_text(json.dumps({'schema_version':2,'issues':issue_ids,'files':files},ensure_ascii=False,indent=2,sort_keys=True)+'\n',encoding='utf-8')
 checksum_files=sorted(x for x in DIST.rglob('*') if x.is_file() and x.name!='SHA256SUMS'); (DIST/'SHA256SUMS').write_text(''.join(f'{sha(p)}  {p.relative_to(DIST).as_posix()}\n' for p in checksum_files),encoding='utf-8')
def main():
 ap=argparse.ArgumentParser(); ap.add_argument('--published-only',action='store_true'); ap.add_argument('--pdf',action='store_true'); ap.add_argument('issues',nargs='*'); args=ap.parse_args(); subprocess.run(['python',str(ROOT/'scripts'/'validate.py'),*args.issues],check=True)
 if DIST.exists(): shutil.rmtree(DIST)
 DIST.mkdir(); shutil.copytree(ROOT/'assets',DIST/'assets');
 if (ROOT/'admin').exists(): shutil.copytree(ROOT/'admin',DIST/'admin')
 env=Environment(loader=FileSystemLoader(ROOT/'templates'),autoescape=select_autoescape(['html','xml','j2'])); tpl=env.get_template('newsletter.html.j2')
 paths=[ROOT/'content'/'issues'/f'{x}.yml' for x in args.issues] if args.issues else sorted((ROOT/'content'/'issues').glob('[0-9][0-9][0-9][0-9]-[0-9][0-9].yml'),reverse=True); cards=[]; built=[]
 for p in paths:
  issue,articles,groups=issue_model(p)
  if args.published_only and issue['status']!='published': continue
  result=tpl.render(issue=issue,articles=articles,groups=groups,pages=issue.get('toc_pages',{})).replace('"/assets/','"assets/').replace('url(/assets/','url(assets/')
  filename=f"so-{issue['number']:02d}-{issue['year']}.html"; (DIST/filename).write_text(result,encoding='utf-8')
  if args.pdf and issue['publication'].get('pdf'):
   from weasyprint import HTML; HTML(filename=str(DIST/filename)).write_pdf(DIST/f"so-{issue['number']:02d}-{issue['year']}.pdf")
  cards.append(f'<li><a href="{filename}">Số {issue["number"]}/{issue["year"]}</a>'+(' · BẢN NHÁP' if issue['status']!='published' else '')+'</li>'); built.append(issue['id'])
 (DIST/'index.html').write_text('<!doctype html><html lang="vi"><meta charset="utf-8"><title>Bản tin PVTM &amp; CBS</title><h1>BẢN TIN PHÒNG VỆ THƯƠNG MẠI &amp; CẢNH BÁO SỚM</h1><ul>'+''.join(cards)+'</ul></html>',encoding='utf-8'); write_manifest(built); print('BUILT:',', '.join(built),'=> dist/')
if __name__=='__main__': main()
