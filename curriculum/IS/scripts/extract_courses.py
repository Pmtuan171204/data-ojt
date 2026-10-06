from html.parser import HTMLParser
from pathlib import Path
import json, csv

ROOT = Path(__file__).resolve().parent.parent
class Tables(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.tables = {}; self.active = None; self.cell = None; self.row = []
    def handle_starttag(self, tag, attrs):
        if tag == 'table':
            key = dict(attrs).get('id')
            if key in ('table-detail','gvSubs'):
                self.active = key; self.tables[key] = []
        if self.active:
            if tag == 'tr': self.row = []
            if tag in ('td','th'): self.cell = []
            if tag == 'br' and self.cell is not None: self.cell.append(' ')
    def handle_data(self, data):
        if self.active and self.cell is not None: self.cell.append(data)
    def handle_endtag(self, tag):
        if not self.active: return
        if tag in ('td','th') and self.cell is not None:
            self.row.append(' '.join(''.join(self.cell).split())); self.cell = None
        if tag == 'tr' and self.row: self.tables[self.active].append(self.row)
        if tag == 'table': self.active = None

with (ROOT/'curricula_is.csv').open(encoding='utf-8-sig',newline='') as f:
    expected = {r['curriculum_code']:int(r['total_credits']) for r in csv.DictReader(f)}
rows=[]; report=[]; seen=set()
for path in sorted((ROOT/'raw').glob('*.html')):
    parser=Tables(); parser.feed(path.read_text(encoding='utf-8-sig'))
    details=dict(r for r in parser.tables.get('table-detail',[]) if len(r)==2)
    code=details.get('CurriculumCode:')
    assert code in expected, (path.name,code)
    assert code not in seen, ('duplicate curriculum source',code)
    seen.add(code)
    table=parser.tables['gvSubs']
    assert table[0]==['Subject Code','Subject Name','Semester','NoCredit','PreRequisite'],table[0]
    keys=set(); total=0
    for cells in table[1:]:
        assert len(cells)==5,cells
        course,name,semester,credits,prereq=cells
        semester=int(semester); credits=int(credits)
        assert course and name and semester>=0 and credits>=0
        assert (course,semester) not in keys,(code,course,semester)
        keys.add((course,semester)); total+=credits
        rows.append([code,course,name,semester,credits,prereq])
    report.append({'curriculum_code':code,'source_file':path.name,'rows':len(table)-1,'sum_credits':total,'listed_total_credits':expected[code],'credit_difference':total-expected[code]})
assert rows, 'No subject rows found'
payload={'headers':['curriculum_code','course_code','course_name','semester','credits','prerequisite'],'rows':rows,'sources':report,'missing_curricula':sorted(set(expected)-seen)}
intermediate = ROOT.parents[1]/'intermediate/curriculum/IS'
intermediate.mkdir(parents=True, exist_ok=True)
(intermediate/'courses_extracted.json').write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in payload.items() if k not in ('rows','headers')},ensure_ascii=False))
