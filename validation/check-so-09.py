from pathlib import Path
import json
from lxml import html as H
R=Path(__file__).resolve().parents[1];s=(R/'public/so-09-2026.html').read_text();d=H.fromstring(s);src=json.loads((R/'validation/so-09-source.json').read_text());actual={}
for el in d.xpath('//*[@data-source-index]'):
 if el.tag=='figure':continue
 idx=int(el.get('data-source-index'));assert idx not in actual,('duplicate source block',idx);actual[idx]=el.text_content()
for b in src['blocks']:assert actual[b['index']]==b['rendered_text'],('source mismatch',b['index'])
assert len(actual)==len(src['blocks'])
assert [e.text_content() for e in d.xpath('//h1[contains(@class,"article-title")]')]==[a['title'] for a in src['articles']]
assert len(d.xpath('//article'))==9 and len(d.xpath('//table'))==3 and len(d.xpath('//figure/img[contains(@src,"chart")]'))==3
for img in d.xpath('//img'):assert (R/'public'/img.get('src')).is_file(),img.get('src')
for a in d.xpath('//a[starts-with(@href,"#")]'):assert d.xpath('//*[@id=$id]',id=a.get('href')[1:]),a.get('href')
assert 'CHƯA XÁC NHẬN' in s and 'assets/fonts/Anton.ttf' in s and (R/'public/assets/fonts/Anton.ttf').exists()
assert not d.xpath('//script')
print('PASS issue 09: all source blocks, 9 articles, 3 tables, 3 charts, assets, font and links')

actual_tables=[[[c.text_content() for c in row.xpath("./th|./td")] for row in t.xpath("./tr|./thead/tr|./tbody/tr")] for t in d.xpath("//table")]
assert actual_tables==src["tables"], "table cells or blanks changed"
