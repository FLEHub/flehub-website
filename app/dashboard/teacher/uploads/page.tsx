import ResourceUploadForm from '@/components/teacher/ResourceUploadForm';

export default function TeacherUploadsPage() {
  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Uploads</h1>
        <p className="text-gray-500 text-sm mt-1">
          Ajoutez des ressources pédagogiques pour vos cours: PDF, audio, images ou vidéos YouTube/Vimeo.
        </p>
      </div>

      <ResourceUploadForm />
    </div>
  );
}
