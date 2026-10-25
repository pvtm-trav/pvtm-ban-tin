from pathlib import Path
import json,re
from lxml import html as H
R=Path(__file__).resolve().parents[1]
s=(R/'public/so-14-2026.html').read_text();root=H.fromstring(s)
expected=json.loads((R/'validation/so-14-source.json').read_text())['articles']
actual={}
for el in root.xpath('//*[@data-source-index]'):
    if el.tag=='figure':continue
    idx=el.get('data-source-index');assert idx not in actual, ('duplicate source block',idx)
    actual[idx]=el.text_content()
for article in expected:
    body=H.fragment_fromstring(article['body_html'],create_parent='div')
    for el in body.xpath('.//*[@data-source-index]'):
        if el.tag=='figure':continue
        assert actual.get(el.get('data-source-index'))==el.text_content(), ('source mismatch',el.get('data-source-index'))
assert len(root.xpath('//h1[contains(@class,"article-title")]'))==14
assert len(root.xpath('//table'))==3
assert len(root.xpath('//figure/img[contains(@src,"chart")]'))==5
for img in root.xpath('//img'):
    path=img.get('src','');assert (R/'public'/path).is_file(),path
for a in root.xpath('//a[starts-with(@href,"#")]'):
    assert root.xpath('//*[@id=$id]',id=a.get('href')[1:]),a.get('href')
assert 'CHƯA XÁC NHẬN' in s
assert not root.xpath('//script')
print('PASS issue 14: 14 article titles, all source paragraphs/tables, 5 charts, images and anchors')
