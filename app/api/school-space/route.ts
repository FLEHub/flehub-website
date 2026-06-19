const [editingStudentId, setEditingStudentId] = useState<string | null>(null);

const openCreateStudent = () => {
  setEditingStudentId(null);
  setStudentForm(emptyStudentForm);
  setStudentOpen(true);
};

const openEditStudent = (student: SchoolStudentRecord) => {
  const enrollment = enrollmentByStudent.get(student.id);
  setEditingStudentId(student.id);
  setStudentForm({
    first_name: student.first_name,
    last_name: student.last_name,
    cefr_level: enrollment?.cefr_level ?? '',
    exam_session_id: enrollment?.exam_session_id ?? '',
  });
  setStudentOpen(true);
};

const saveStudent = async () => {
  setSaving(true);
  try {
    if (editingStudentId) {
      await apiPost({
        action: 'updateSchoolStudent',
        student_id: editingStudentId,
        first_name: studentForm.first_name,
        last_name: studentForm.last_name,
        cefr_level: studentForm.cefr_level || undefined,
        exam_session_id: studentForm.exam_session_id || undefined,
      });
      toast({ title: 'Élève modifié', description: 'Les informations ont été mises à jour.' });
    } else {
      await apiPost({
        action: 'createSchoolStudent',
        first_name: studentForm.first_name,
        last_name: studentForm.last_name,
        cefr_level: studentForm.cefr_level || undefined,
        exam_session_id: studentForm.exam_session_id || undefined,
      });
      toast({ title: 'Élève ajouté', description: 'Le registre de votre école a été mis à jour.' });
    }
    setStudentOpen(false);
    setEditingStudentId(null);
    await load();
  } catch (err) {
    toast({ title: 'Erreur', description: err instanceof Error ? err.message : 'Action impossible.' });
  } finally {
    setSaving(false);
  }
};

<TableCell className="text-right space-x-2">
  <Button size="sm" variant="outline" onClick={() => openEditStudent(student)}>
    <Settings className="w-3.5 h-3.5 text-gray-600" />
  </Button>
  <Button size="sm" variant="outline" onClick={() => deleteStudent(student.id)}>
    <Trash2 className="w-3.5 h-3.5 text-red-600" />
  </Button>
</TableCell>

<Dialog
  open={studentOpen}
  onOpenChange={(open) => {
    setStudentOpen(open);
    if (!open) setEditingStudentId(null);
  }}
>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>{editingStudentId ? "Modifier l'élève" : 'Ajouter un élève'}</DialogTitle>
    </DialogHeader>

<Button
  onClick={saveStudent}
  disabled={saving || !studentForm.first_name.trim() || !studentForm.last_name.trim()}
  className="bg-[#00A550] hover:bg-[#008040] text-white"
>
  {editingStudentId ? 'Mettre à jour' : 'Enregistrer'}
</Button>
