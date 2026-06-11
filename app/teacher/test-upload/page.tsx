import ResourceUploadForm from '@/components/teacher/ResourceUploadForm';

export default function TestUploadPage() {
  return (
    <div className="max-w-2xl mx-auto p-8">
      <h1 className="text-2xl font-bold mb-6">Ajouter une ressource</h1>
      <ResourceUploadForm />
    </div>
  );
}
