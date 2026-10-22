#!/usr/bin/env python3
"""Finalize PR-v2.2: inline legacy JSON bodies into Markdown and remove issue-specific chrome. One-time migration; safe to re-run."""
from __future__ import annotations
import json,re
from pathlib import Path
import yaml
from lxml import html as LH
ROOT=Path(__file__).resolve().parents[1]; ISSUES=('2026-21','2026-39')
def clean_html(raw:str)->str:
    root=LH.fragment_fromstring(raw or '<p></p>',create_parent='div')
    chrome=".//div[contains(concat(' ',normalize-space(@class),' '),' screen-category ')] | .//div[contains(concat(' ',normalize-space(@class),' '),' section-header ')] | .//h1[contains(concat(' ',normalize-space(@class),' '),' article-title ')]"
    for node in list(root.xpath(chrome)):
        parent=node.getparent()
        if parent is not None: parent.remove(node)
    for node in list(root.xpath('.//div[@data-source-block]')):
        parent=node.getparent()
        if parent is None: continue
        idx=parent.index(node)
        if node.text and node.text.strip():
            span=LH.Element('span'); span.text=node.text; parent.insert(idx,span); idx+=1
        for child in list(node): node.remove(child); parent.insert(idx,child); idx+=1
        parent.remove(node)
    for node in reversed(list(root.xpath('.//div'))):
        if not node.attrib and not (node.text or '').strip() and len(node)==0:
            parent=node.getparent()
            if parent is not None: parent.remove(node)
    return ''.join(LH.tostring(e,encoding='unicode',method='html') for e in root)
def split_frontmatter(text:str):
    m=re.match(r'\A---\s*\n(.*?)\n---\s*\n?(.*)\Z',text,re.S)
    if not m: raise ValueError('missing front matter')
    return yaml.safe_load(m.group(1)) or {},m.group(2)
def main():
    migrated=0
    for issue in ISSUES:
        for md in sorted((ROOT/'content'/'articles'/issue).glob('*.md')):
            meta,body=split_frontmatter(md.read_text(encoding='utf-8')); legacy=meta.pop('legacy_source',None)
            if legacy:
                obj=json.loads((ROOT/legacy).read_text(encoding='utf-8'))
                if obj.get('id')!=meta.get('id') or obj.get('title')!=meta.get('title') or obj.get('category')!=meta.get('category'): raise SystemExit(f'metadata mismatch: {md}')
                body=clean_html(obj.get('body_html',''))
            if not body.strip(): raise SystemExit(f'empty body: {md}')
            fm=yaml.safe_dump(meta,allow_unicode=True,sort_keys=False,width=1000).strip(); md.write_text(f'---\n{fm}\n---\n{body.strip()}\n',encoding='utf-8'); migrated+=1
    tpl=ROOT/'templates'/'newsletter.html.j2'; text=tpl.read_text(encoding='utf-8').replace('BẢN TIN PVTM & CBS - Số 39-2026','BẢN TIN PVTM & CBS - Số {{ issue.number }}-{{ issue.year }}').replace('url(/assets/','url(assets/'); tpl.write_text(text,encoding='utf-8')
    print(f'FINALIZED: {migrated} Markdown articles; shared template parameterized')
if __name__=='__main__': main()
