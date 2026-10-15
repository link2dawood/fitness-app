from docx import Document
from docx.shared import Pt, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
text = '''Dennis M. Ritchie and Ken Thompson describe UNIX as an interactive operating system that allows multiple users to work on a modest computer. The paper explains how its file system, process management, and command interpreter provide useful capabilities without requiring a large or complicated implementation. UNIX organizes files through a directory hierarchy and allows additional storage volumes to be attached to that structure. Ordinary files contain data whose meaning is determined by applications, while special files provide access to devices through familiar reading and writing operations. File permissions control access, and internal records called inodes store information needed to locate and manage files. Processes are created through fork, which produces a child process, while execute replaces a process's program. Other operations allow processes to wait for completion or terminate. Pipes transfer data between related processes, making it possible to combine programs into sequences that perform larger tasks. The shell interprets commands as an ordinary user program. It supports input and output redirection, background execution, and command files, and users can replace it with another interface. Rewriting the system in C made it easier to understand and modify, although its size increased. The authors explain that limited resources, a preference for interactive programming, and daily use of their own software shaped its development. Usage figures demonstrate its practical role in programming and document preparation, while reliability observations acknowledge both hardware and software failures. The paper's central contribution is showing how carefully chosen, compatible mechanisms can produce a capable operating system with relatively little equipment and development effort.'''
doc = Document()
sec = doc.sections[0]
sec.top_margin = sec.bottom_margin = sec.left_margin = sec.right_margin = Inches(1)
style = doc.styles['Normal']
style.font.name = 'Times New Roman'
style.font.size = Pt(12)
p = doc.add_paragraph(text)
p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
p.paragraph_format.line_spacing = 1.15
p.paragraph_format.space_after = Pt(0)
for r in p.runs:
    r.font.name = 'Times New Roman'
    r.font.size = Pt(12)
doc.save('output/doc/unix-paper-summary.docx')
print('Word count:', len(text.split()))
