#!/usr/bin/env python3








PROBLEM_DATA = """<problem>
  <style>h3.hd-3{font-size:1.2em!important;font-weight:600!important;}</style>
  <p><b>1. </b>Το σθένος του ατόμου του άνθρακα είναι ίσο με:</p>
  <numericalresponse answer="4">
    <textline inline="1"/>
  </numericalresponse>
  <p><b>2. </b>Η θεωρία της σχετικότητας προτάθηκε για πρώτη φορά από τον Αϊνστάιν το έτος:</p>
  <numericalresponse answer="1905">
    <responseparam type="tolerance" default="1"/>
    <textline inline="1"/>
  </numericalresponse>
  <p><b>3. </b>Η Φιλική Εταιρεία ιδρύθηκε στην Οδησσό το έτος:</p>
  <numericalresponse answer="1814">
    <responseparam type="tolerance" default="1"/>
    <textline inline="1"/>
  </numericalresponse>
  <p><b>4. </b>Ο Μέγας Αλέξανδρος πέθανε στη Βαβυλώνα το έτος:</p>
  <numericalresponse answer="323">
    <responseparam type="tolerance" default="1"/>
    <textline inline="1"/>
    <p style="display:inline">π.Χ.</p>
  </numericalresponse>
  <p>Σημείωση: Όταν η ζητούμενη αριθμητική απάντηση έχει μονάδες (π.χ. sec, cm, Kg κ.λπ.) ή απαιτεί κάποιον επιπλέον προσδιορισμό (όπως π.Χ.) τότε αυτός λέγεται ρητά στην εκφώνηση ή/και αναγράφεται έξω από το κουτί της απάντησης. Μέσα στο κουτί μπαίνει μόνο ο αριθμός και ποτέ οι μονάδες ή ο όποιος επιπλέον προσδιορισμός.</p>
  <p><b>5. </b>Ένα σώμα αφήνεται να πέσει από ύψος 20m στο ομογενές πεδίο βαρύτητας της Γης (<i>g</i>=10m/s²) χωρίς τριβή. Ύστερα από πόσα δευτερόλεπτα θα φτάσει στο έδαφος;</p>
  <numericalresponse answer="2">
    <responseparam type="tolerance" default="15%"/>
    <p style="display:inline">\(t=\)</p>
    <textline size="15" inline="1"/>
    <p style="display:inline">sec</p>
  </numericalresponse>
</problem>"""

from xmodule.modulestore.django import modulestore
from opaque_keys.edx.keys import CourseKey
from django.contrib.auth import get_user_model
ms = modulestore()
user_id = get_user_model().objects.get(username="openedx").id
course = ms.get_course(CourseKey.from_string("course-v1:OpenedX+DemoX+DemoCourse"))
problem = ms.create_child(user_id, course.get_children()[0].get_children()[0].children[0], "problem")
problem.data = PROBLEM_DATA
rendered = problem.get_problem_html()
print(rendered)


'''
from xmodule.capa.capa_problem import LoncapaProblem, LoncapaSystem
from xmodule.modulestore.django import XBlockI18nService
from fs.memoryfs import MemoryFS

class FakeTranslations(XBlockI18nService):
    def __init__(self, translations):
        pass
    def ugettext(self, msgid):
        return msgid
    gettext = ugettext
    @staticmethod
    def translator(locales_map):
        def _translation(domain, localedir=None, languages=None):
            if languages:
                language = languages[0]
                if language in locales_map:
                    return FakeTranslations(locales_map[language])
            return gettext.NullTranslations()
        return _translation

rendered = LoncapaProblem(
    problem_text=PROBLEM_DATA,
    id="fake-html-id",
    state={
        'done': False,
        'correct_map': {},
        'correct_map_history': [],
        'student_answers': {},
        'has_saved_answers': False,
        'input_state': {},
        'seed': 1,
    },
    seed=1,
    capa_system=LoncapaSystem(
        ajax_url=None,
        anonymous_student_id=None,
        cache=None,
        can_execute_unsafe_code=None,
        get_python_lib_zip=None,
        DEBUG=None,
        i18n=FakeTranslations({}),
        render_template=None,
        resources_fs=MemoryFS(),
        seed=None,
        xqueue=None,
        matlab_api_key=None,
    ),
    capa_block=None,
).get_html()
print(rendered)
'''

