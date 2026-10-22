#!/usr/bin/env python3
"""Validate Pipeline v2 YAML issues, Markdown articles and referenced assets."""
from __future__ import annotations
import argparse, re, sys
from pathlib import Path
import yaml
from jsonschema import Draft202012Validator, FormatChecker
from lxml import html as LH
ROOT=Path(__file__).resolve().parents[1]; ISSUES=ROOT/'content'/'issues'; ARTICLES=ROOT/'content'/'articles'; SCHEMA=ROOT/'schemas'/'issue.schema.json'
CATEGORIES=['TIN TRONG NƯỚC','TIN NƯỚC NGOÀI','THÔNG TIN XUẤT NHẬP KHẨU']
def load_yaml(path):
 data=yaml.safe_load(path.read_text(encoding='utf-8'))
 if not isinstance(data,dict): raise ValueError(f'{path}: YAML phải là object')
 return data
def split_frontmatter(path):
 text=path.read_text(encoding='utf-8'); m=re.match(r'\A---\s*\n(.*?)\n---\s*\n?(.*)\Z',text,re.S)
 if not m: raise ValueError(f'{path}: thiếu YAML front matter')
 meta=yaml.safe_load(m.group(1)) or {}
 if not isinstance(meta,dict): raise ValueError(f'{path}: front matter không hợp lệ')
 return meta,m.group(2)
def asset_path(value): return ROOT/value.lstrip('/')
def validate_issue(path,schema):
 errors=[]; issue=load_yaml(path); validator=Draft202012Validator(schema,format_checker=FormatChecker())
 for e in sorted(validator.iter_errors(issue),key=lambda x:list(x.path)): errors.append(f"{path}: schema: {'.'.join(map(str,e.path)) or '<root>'}: {e.message}")
 if errors:return errors
 expected=f"{issue['year']:04d}-{issue['number']:02d}"
 if path.name!=expected+'.yml' or issue['id']!=expected: errors.append(f'{path}: tên file/id phải là {expected}')
 if [s['id'] for s in issue['sections']]!=['domestic','foreign','trade']: errors.append(f'{path}: sections phải theo thứ tự domestic, foreign, trade')
 if [s['title'] for s in issue['sections']]!=CATEGORIES: errors.append(f'{path}: ba chuyên mục không đúng Design System')
 refs=[a for s in issue['sections'] for a in s['articles']]
 if len(refs)!=len(set(refs)): errors.append(f'{path}: article id bị lặp giữa các chuyên mục')
 for aid in issue['cover']['headline_articles']:
  if aid not in refs: errors.append(f'{path}: headline article {aid} không có trong sections')
 for value in [issue['cover']['hero'],*issue['cover']['feature_images']]:
  if not asset_path(value).is_file(): errors.append(f'{path}: thiếu asset {value}')
 for section in issue['sections']:
  for aid in section['articles']:
   ap=ARTICLES/issue['id']/f'{aid}.md'
   if not ap.is_file(): errors.append(f'{path}: thiếu bài {ap.relative_to(ROOT)}'); continue
   try: meta,body=split_frontmatter(ap)
   except Exception as ex: errors.append(str(ex)); continue
   expected_id=f"{issue['id']}-{aid}"
   if meta.get('id')!=expected_id: errors.append(f'{ap}: id phải là {expected_id}')
   if not str(meta.get('title','')).strip(): errors.append(f'{ap}: thiếu title')
   if meta.get('category')!=section['title']: errors.append(f"{ap}: category phải là {section['title']}")
   if 'legacy_source' in meta: errors.append(f'{ap}: legacy_source không còn được phép trong Pipeline v2')
   if not body.strip(): errors.append(f'{ap}: nội dung Markdown rỗng')
   try:
    frag=LH.fragment_fromstring(body or '<p></p>',create_parent='div')
    if frag.xpath('.//script|.//iframe|.//object|.//embed'): errors.append(f'{ap}: chỉ cho phép HTML tĩnh')
    for el in frag.iter():
     for key,val in el.attrib.items():
      low=val.strip().lower()
      if key.lower().startswith('on') or (key in ('href','src') and low.startswith('javascript:')): errors.append(f'{ap}: thuộc tính HTML không an toàn')
      if key=='src' and val.startswith('/assets/') and not asset_path(val).is_file(): errors.append(f'{ap}: thiếu asset {val}')
   except Exception as ex: errors.append(f'{ap}: HTML/Markdown fragment lỗi: {ex}')
 return errors
def main():
 parser=argparse.ArgumentParser(); parser.add_argument('issues',nargs='*'); args=parser.parse_args(); import json
 schema=json.loads(SCHEMA.read_text(encoding='utf-8')); paths=[ISSUES/f'{x}.yml' for x in args.issues] if args.issues else sorted(ISSUES.glob('[0-9][0-9][0-9][0-9]-[0-9][0-9].yml'))
 if not paths: print('Không tìm thấy issue YAML v2.',file=sys.stderr); return 2
 errors=[]
 for p in paths:
  if not p.is_file(): errors.append(f'{p}: không tồn tại')
  else: errors.extend(validate_issue(p,schema))
 if errors: print('\n'.join('ERROR: '+e for e in errors),file=sys.stderr); return 1
 print(f'VALID: {len(paths)} issue(s): '+', '.join(p.stem for p in paths)); return 0
if __name__=='__main__': raise SystemExit(main())
