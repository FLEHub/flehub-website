/* ============================================================
   ÉTAPE 2 — Fichier : components/school/school-space-client.tsx
   ============================================================ */

/* ---- A) Ajouter "editingStudentId" à côté des autres useState ----
   Cherche cette ligne (vers le début du composant) :

     const [studentOpen, setStudentOpen] = useState(false);

   Et ajoute juste après :
*/

const [editingStudentId, setEditingStudentId] = useState<string | null>(null);

/* ---- B) Remplacer la fonction openCreateStudent ----
   Cherche :

     const openCreateStudent = () => {
       setStudentForm(emptyStudentForm);
       setStudentOpen(true);
     };

   Remplace-la par ces DEUX fonctions :
*/

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

/* ---- C) Remplacer la fonction saveStudent ----
   Cherche :

     const saveStudent = async () => {
       setSaving(true);
       try {
         await apiPost({
           action: 'createSchoolStudent',
           first_name: studentForm.first_name,
           last_name: studentForm.last_name,
           cefr_level: studentForm.cefr_level || undefined,
           exam_session_id: studentForm.exam_session_id || undefined,
         });
         toast({ title: 'Élève ajouté', description: 'Le registre de votre école a été mis à jour.' });
         setStudentOpen(false);
         await load();
       } catch (err) {
         toast({ title: 'Erreur', description: err instanceof Error ? err.message : 'Action impossible.' });
       } finally {
         setSaving(false);
       }
     };

   Remplace-la entièrement par :
*/

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

/* ---- D) Ajouter le bouton "Modifier" dans le tableau ----
   Cherche, dans la section section === 'students', ce bloc :

     <TableCell className="text-right">
       <Button size="sm" variant="outline" onClick={() => deleteStudent(student.id)}>
         <Trash2 className="w-3.5 h-3.5 text-red-600" />
       </Button>
     </TableCell>

   Remplace-le par :
*/

<TableCell className="text-right space-x-2">
  <Button size="sm" variant="outline" onClick={() => openEditStudent(student)}>
    <Settings className="w-3.5 h-3.5 text-gray-600" />
  </Button>
  <Button size="sm" variant="outline" onClick={() => deleteStudent(student.id)}>
    <Trash2 className="w-3.5 h-3.5 text-red-600" />
  </Button>
</TableCell>

/* ---- E) Mettre à jour le Dialog (titre + bouton "Enregistrer") ----
   Cherche, tout en bas du fichier :

     <Dialog open={studentOpen} onOpenChange={setStudentOpen}>
       <DialogContent>
         <DialogHeader>
           <DialogTitle>Ajouter un élève</DialogTitle>
         </DialogHeader>

   Remplace les 3 lignes du DialogHeader par :
*/

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

/* ---- F) Adapter le bouton final du Dialog (optionnel mais conseillé) ----
   Cherche, en bas du Dialog :

     <Button
       onClick={saveStudent}
       disabled={saving || !studentForm.first_name.trim() || !studentForm.last_name.trim()}
       className="bg-[#00A550] hover:bg-[#008040] text-white"
     >
       Enregistrer
     </Button>

   Remplace "Enregistrer" par :
*/

<Button
  onClick={saveStudent}
  disabled={saving || !studentForm.first_name.trim() || !studentForm.last_name.trim()}
  className="bg-[#00A550] hover:bg-[#008040] text-white"
>
  {editingStudentId ? 'Mettre à jour' : 'Enregistrer'}
</Button>
