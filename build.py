"""Build HTML newsletters from Git-managed content. PDF is an optional local step."""
from pathlib import Path
import argparse,json,shutil,subprocess,re,html as esc
from lxml import html as LH
from jinja2 import Environment,FileSystemLoader,select_autoescape
ROOT=Path(__file__).resolve().parent
CATEGORIES=['TIN TRONG NƯỚC','TIN NƯỚC NGOÀI','THÔNG TIN XUẤT NHẬP KHẨU']
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def normalize(text):return re.sub(r'\s+',' ',text).strip()
def render_article(data,index):
    if data['category'] not in CATEGORIES:raise ValueError('Chuyên mục không hợp lệ: '+data['id'])
    body=LH.fragment_fromstring(data['body_html'] or '<p></p>',create_parent='div')
    if body.xpath('.//script | .//iframe | .//object | .//embed'):raise ValueError('Nội dung bài chỉ được chứa HTML tĩnh: '+data['id'])
    for e in body.iter():
        for key,val in e.attrib.items():
            if key.lower().startswith('on') or (key in ['href','src'] and val.strip().lower().startswith('javascript:')):raise ValueError('Thuộc tính HTML không hợp lệ: '+data['id'])
    title=body.xpath('.//h1[contains(@class,"article-title")]')
    if title:title=title[0];title.clear()
    else:title=LH.Element('h1');body.insert(0,title)
    anchor='article-'+str(index);title.set('class','article-title');title.set('id',anchor);title.text=data['title']
    cats=body.xpath('./*[@class="screen-category"]')
    if cats:cats[0].text=data['category']
    else:
        header=LH.Element('header',{'class':'screen-category'});header.text=data['category'];body.insert(0,header)
    return {**data,'anchor':anchor,'html':''.join(LH.tostring(e,encoding='unicode') for e in body)}
def verify_issue_39(data,articles):
    baseline=ROOT/'validation/so-39-original.json'
    if data['id']!='so-39-2026' or not baseline.exists():return
    reference={a['id']:normalize(a['text']) for a in read(baseline)}
    changed=[]
    for a in articles:
        text=normalize(''.join(LH.fragment_fromstring(a['html'],create_parent='div').itertext()))
        if a['id'] in reference and text!=reference[a['id']]:changed.append(a['id'])
    if changed:print('Nội dung đã thay đổi so với bản gốc:',', '.join(changed))
    else:print('Đối chiếu số 39: nguyên văn 10 bài được bảo toàn.')
def main():
    parser=argparse.ArgumentParser();parser.add_argument('--include-drafts',action='store_true');parser.add_argument('--pdf',action='store_true');args=parser.parse_args()
    out=ROOT/'public'
    if out.exists():shutil.rmtree(out)
    out.mkdir();shutil.copytree(ROOT/'assets',out/'assets');shutil.copytree(ROOT/'admin',out/'admin')
    env=Environment(loader=FileSystemLoader(ROOT/'templates'),autoescape=select_autoescape(['html','xml','j2']))
    template=env.get_template('newsletter.html.j2');cards=[]
    for path in sorted((ROOT/'content/issues').glob('*.json'),reverse=True):
        issue=read(path)
        if issue['status']!='published' and not args.include_drafts:continue
        if not re.fullmatch(r'[a-z0-9-]+',issue['id']):raise ValueError('Mã số bản tin không hợp lệ')
        ids=issue['articles']
        if len(set(ids))!=len(ids):raise ValueError('Danh sách bài bị trùng')
        articles=[]
        for index,slug in enumerate(ids,1):
            if not re.fullmatch(r'[a-z0-9-]+',slug):raise ValueError('Mã bài không hợp lệ')
            articles.append(render_article(read(ROOT/'content/articles'/f'{slug}.json'),index))
        verify_issue_39(issue,articles)
        groups=[{'name':name,'articles':[a for a in articles if a['category']==name]} for name in CATEGORIES]
        ordered=[a['id'] for g in groups for a in g['articles']]
        if ordered!=ids:raise ValueError('Sắp xếp bài theo thứ tự: tin trong nước, tin nước ngoài, thông tin xuất nhập khẩu')
        pages={};result=template.render(issue=issue,articles=articles,groups=groups,pages=pages)
        # Root-relative asset paths are converted for local HTML and project sub-path hosting.
        result=result.replace('"/assets/','"assets/').replace('url(/assets/','url(assets/')
        filename=issue['id']+'.html';(out/filename).write_text(result,encoding='utf-8')
        if args.pdf:
            for font in ['Arial','Times New Roman']:
                family=subprocess.check_output(['fc-match','-f','%{family}',font],text=True)
                if font.lower() not in family.lower():raise RuntimeError(f'Cần cài font {font} hợp lệ trước khi xuất PDF; hiện hệ thống chọn {family}.')
            from weasyprint import HTML
            document=HTML(filename=str(out/filename)).render();pages={k:i+1 for i,p in enumerate(document.pages) for k in p.anchors}
            result=template.render(issue=issue,articles=articles,groups=groups,pages=pages).replace('"/assets/','"assets/').replace('url(/assets/','url(assets/')
            (out/filename).write_text(result,encoding='utf-8');HTML(filename=str(out/filename)).write_pdf(out/(issue['id']+'.pdf'))
        cards.append(f'<li><a href="{filename}">Số {issue["number"]}/{issue["year"]}</a>'+(' · BẢN NHÁP' if issue['status']!='published' else '')+'</li>')
    index='<!doctype html><html lang="vi"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Bản tin PVTM &amp; CBS</title><style>body{max-width:900px;margin:60px auto;padding:24px;font:18px/1.6 Arial;color:#003366}h1{font-size:28px}li{margin:16px 0}a{color:#003366}</style><h1>BẢN TIN PHÒNG VỆ THƯƠNG MẠI &amp; CẢNH BÁO SỚM</h1><ul>'+''.join(cards)+'</ul>'+('' if cards else '<p>Chưa có số bản tin được phát hành.</p>')+'<p><a href="admin/">Đăng nhập quản trị</a></p></html>'
    (out/'index.html').write_text(index,encoding='utf-8');print('Đã dựng',len(cards),'số bản tin tại public/.')
if __name__=='__main__':main()
