from pathlib import Path
from html.parser import HTMLParser
import re,json,csv
ROOT=Path(__file__).resolve().parent.parent
CODE='BIT_IS_K18D_19A'
class Parser(HTMLParser):
 def __init__(self):
  super().__init__(); self.tables=[];self.table=None;self.cell=None;self.row=[]
 def handle_starttag(self,t,a):
  if t=='table':self.table=[]
  if self.table is not None:
   if t=='tr':self.row=[]
   if t in ('td','th'):self.cell=[]
   if t=='br' and self.cell is not None:self.cell.append(' ')
 def handle_data(self,d):
  if self.cell is not None:self.cell.append(d)
 def handle_endtag(self,t):
  if t in ('td','th') and self.cell is not None:
   self.row.append(' '.join(''.join(self.cell).split()));self.cell=None
  if t=='tr' and self.table is not None and self.row:self.table.append(self.row)
  if t=='table' and self.table is not None:self.tables.append(self.table);self.table=None
with (ROOT/'combo'/CODE/'combos.csv').open(encoding='utf-8-sig',newline='') as f:
 known={r['combo_name']:r['combo_id'] for r in csv.DictReader(f)}
combos=[];courses=[];sources=[]
for p in sorted((ROOT/'raw/combo'/CODE).glob('*.html')):
 text=p.read_text(encoding='utf-8-sig');m=re.search(r'saved from url=.*?(https://flm\.fpt\.edu\.vn/Compo/Detail/(\d+)\?curriculumID=(\d+))',text)
 parser=Parser();parser.feed(text)
 meta=next(t for t in parser.tables if t and t[0][0]=='Combo Name')
 metadata=dict(r for r in meta if len(r)==2)
 name=metadata['Combo Name'];note=metadata.get('Note','')
 if m:
  url,cid,curid=m.groups();assert curid=='3226',(p.name,curid)
 else:
  assert name in known,(p.name,'Unrecognized combo name')
  cid=known[name];url=''
 combos.append([CODE,cid,name,'',note])
 table=next(t for t in parser.tables if t and t[0][:4]==['ID','Subject Code','Subject Name','Semester'])
 for r in table[1:]:
  assert len(r)>=5,r
  rid,course,title,semester,remark=r[:5]
  assert rid and course and title
  courses.append([CODE,cid,rid,course,title,int(semester),'','',remark])
 sources.append({'file':p.name,'url':url,'combo_id':cid,'rows':len(table)-1,'note':note})
with (ROOT/'combo'/CODE/'combos.csv').open(encoding='utf-8-sig',newline='') as f:expected={r['combo_id'] for r in csv.DictReader(f)}
assert {r[1] for r in combos}==expected
assert len(combos)==len(expected)==7
assert len({(r[1],r[2]) for r in courses})==len(courses)
out=ROOT.parents[1]/'intermediate/curriculum/IS';out.mkdir(parents=True,exist_ok=True)
payload={'code':CODE,'combos':[['curriculum_code','combo_id','combo_name','selection_group','note'],*combos],'courses':[['curriculum_code','combo_id','combo_subject_id','course_code','course_name','semester','credits','prerequisite','note'],*courses],'sources':sources}
(out/'combo_extracted.json').write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(sources,ensure_ascii=True))

