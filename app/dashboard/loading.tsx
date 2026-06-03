export default function DashboardLoading() {
  return (
    <div className="flex min-h-[50vh] items-center justify-center p-6">
      <div className="text-center">
        <div className="mx-auto mb-3 h-8 w-8 animate-spin rounded-full border-2 border-[#00A550] border-t-transparent" />
        <p className="text-sm text-gray-500">Loading dashboard...</p>
      </div>
    </div>
  )
}
